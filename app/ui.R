if (!require("shiny")) {
  install.packages("shiny")
  library(shiny)
}
if (!require("shinyWidgets")) {
  install.packages("shinyWidgets")
  library(shinyWidgets)
}
if (!require("shinythemes")) {
  install.packages("shinythemes")
  library(shinythemes)
}
if (!require("leaflet")) {
  install.packages("leaflet")
  library(leaflet)
}
if (!require("leaflet.extras")) {
  install.packages("leaflet.extras")
  library(leaflet.extras)
}

if (!require("shinydashboard")) {
  install.packages("shinydashboard")
  library(shiny)
}

if (!require("tidyr")) {
  install.packages("tidyr")
  library(tidyr)
}

if (!require("dplyr")) {
  install.packages("dplyr")
  library(dplyr)
}

unit_data = read.csv("../out/units_cleaned.csv")

df<-read.csv("../data/Affordable_Housing_Production_by_Building.csv")
data<-df %>% drop_na(Longitude)
data<-data %>% drop_na(Latitude)
data = data %>% select(Project.ID, Project.Name, Project.Start.Date, Borough, Latitude, Longitude, Extremely.Low.Income.Units, Very.Low.Income.Units, Low.Income.Units, Moderate.Income.Units, Middle.Income.Units, Other.Income.Units)

borough = unique(data$Borough)
income_level = c('Extremely.Low.Income.Units', 'Very.Low.Income.Units', 'Low.Income.Units', 'Moderate.Income.Units', 'Middle.Income.Units', 'Other.Income.Units')


# Define UI for application that draws a histogram
shinyUI(
  dashboardPage(
    skin = "black",
    
    
    dashboardHeader(
      title = "NYC Housing"
    ),
    
    dashboardSidebar(
      sidebarMenu(
        menuItem("Home", tabName = "Home", icon = icon("home")),
        menuItem("Housing Unit Map", tabName = "Group1", icon = icon("location-dot")),
        menuItem("Selected Income Level Trend", tabName = "Group2", icon = icon("chart-line")),
        menuItem("Housing Maintenance Trend", tabName = "Group3A", icon = icon("chart-line")),
        menuItem("Housing Maintenance Map", tabName = "Group3B", icon = icon("map")),
        menuItem("Appendix", tabName = "Appendix", icon = icon("info"))
      )
    ),
    
    dashboardBody(
      tags$style(type="text/css",
                 "text {font-family: helvetica,arial,sans-serf}",
                 ".shiny-output-error { visibility: hidden; }",
                 ".shiny-output-error:before { visibility: hidden; }"
      ),
      
      tabItems(
        
        tabItem(tabName = "Home",
                fluidPage(
                  theme = shinytheme("cerulean"),
                  tags$head(tags$style(HTML('
                    .intro-header {
                      background-color: #007bff;
                      color: #fff;
                      padding: 10px;
                      font-size: 24px;
                      font-weight: bold;
                      margin-bottom: 20px;
                    }
                    .user-guide-header {
                      background-color: #007bff;
                      color: #fff;
                      padding: 10px;
                      font-size: 18px;
                      font-weight: bold;
                      margin-bottom: 10px;
                    }
                    .user-guide-text {
                      background-color: #f8f9fa;
                      padding: 10px;
                      font-size: 16px;
                    }
                    .intro-text {
                      background-color: #f8f9fa;
                      padding: 10px;
                      font-size: 20px;
                    }
                  '))),
                  
                  tags$div(class = "intro-header", "Introduction"),
                  tags$p(class = "intro-text", "Covid-19 has a profound impact in New York city. Also, having a nice place to live is essential for everyone's survival and well-being. In this app, we track the NYC housing trends before and after covid-19. See 'User Guide' below to explore interesting trends and findings.  "
                  ),
                  
                  tags$div(class = "user-guide-header", "User Guide"),
                  
                  tags$div(class = "user-guide-text", 
                           tags$p(style = "font-size: 20px", "This app contains 5 pages and tracks the trend of NYC housing chronologically and geographically from various aspects: "),
                           tags$ul(
                             tags$li(style = "font-size: 20px", "Home: Introduction"),
                             tags$li(style = "font-size: 20px", "Unit Map: The distribution of NYC housing with different number of bedrooms"),
                             
                             tags$li(style = "font-size: 20px", "Income Level: The trend of NYC housing for different income levels"),
                             
                             tags$li(style = "font-size: 20px", "Housing Maintenance Trend: The trend of NYC housing maintenance performance"),
                             tags$li(style = "font-size: 20px", "Housing Maintenance Map: The distribution of NYC housing maintenance performance"),
                             
                             tags$li(style = "font-size: 20px", "Appendix: Data source, authors, and other statements")
                           )
                  )
                )
                
                
        ),  #Home
        
        tabItem(tabName = "Group1",
                fluidPage(
                  fluidRow(
                    column(6,
                           selectInput(inputId = "group1_year",
                                       label = "Select Year",
                                       selected = 2022,
                                       choices = seq(min(unit_data$Start.Year),
                                                     max(unit_data$Start.Year))),
                           ),
                    column(6,
                           selectInput(inputId = "group1_unit",
                                       label = "Select Unit",
                                       selected = "Total_Units",
                                       choices = c("Studio_Units","One_Bedroom_Units","Two_Bedroom_Units","Three_Bedroom_Units", "Four_Bedroom_Units", "Five_Bedroom_Units", "Six_Bedroom_Units","Total_Units")),
                           
                    ),
                    column(12,
                           leafletOutput("group1_map", height = '800px'))
                  )
                )
        ),  #Group 1
        
        tabItem(tabName = "Group2",
                fluidPage(
                  
                  #navbar structure
             
                                      sidebarLayout(
                                        sidebarPanel(
                                          
                                          selectInput(inputId = "base",
                                                      label = "Select a Income Level",
                                                      choices = income_level),
                                          
                                          selectInput(inputId = "bor_type",
                                                      label = "Select a Comparing Borough",
                                                      choices = borough),
                                          
                                          textInput(inputId = "timefrom",
                                                    label = "from:",
                                                    value = "2014"),
                                          
                                          textInput(inputId = "timeto",
                                                    label = "To:",
                                                    value = "2022"),
                                          
                                          helpText("Format example: any year between 2014 and 2022")
                                        ),
                                        
                                        mainPanel(
                                          plotOutput("timePlot")
                                        )
                                      ),
                             
                                
                )
        ),  #Group 2
        
        
        tabItem(tabName = "Group3A",
                fluidPage(
                  
                  # Application title
                  titlePanel("Maintenance overview"),
                  
                  # Add a dropdown menu to select a borough
                  sidebarPanel(
                    radioButtons("checkGroup", label = h3("Choose a borough"), 
                                 choices = list("All boroughs" = 0, "Manhattan" = 1, "Bronx" = 2,"Brooklyn" = 3,"Queens" = 4,"Staten Island" = 5),
                                 selected = 0),
                  ),
                  
                  # Add the main content to the app
                  mainPanel(
                    plotOutput("line_plot1"),
                    plotOutput("line_plot2"),
                    plotOutput("line_plot3")
                  )
                )
        ),  #Group 3
        
        tabItem(tabName = 'Group3B',
                fluidPage(
                  titlePanel('Comparison before and during covid'),
                  fluidRow(
                    splitLayout(cellWidths = c("50%", "50%"), 
                                leafletOutput("left_map",width="100%",height=1200),
                                leafletOutput("right_map",width="100%",height=1200)))
                )
        ),
        
        tabItem(tabName = "Appendix",                 fluidPage(
          theme = shinytheme("cerulean"),
          tags$head(tags$style(HTML('
                    .intro-header {
                      background-color: #007bff;
                      color: #fff;
                      padding: 10px;
                      font-size: 24px;
                      font-weight: bold;
                      margin-bottom: 20px;
                    }
                    .user-guide-header {
                      background-color: #007bff;
                      color: #fff;
                      padding: 10px;
                      font-size: 18px;
                      font-weight: bold;
                      margin-bottom: 10px;
                    }
                    .user-guide-text {
                      background-color: #f8f9fa;
                      padding: 10px;
                      font-size: 16px;
                    }
                    .intro-text {
                      background-color: #f8f9fa;
                      padding: 10px;
                      font-size: 20px;
                    }
                  '))),
          
          tags$div(class = "user-guide-header", "Data Source"),
          
          tags$div(class = "user-guide-text", 
                   tags$ul(
                     tags$li(style = "font-size: 20px", "NYC Open data: Affordable Housing Production by Building (https://data.cityofnewyork.us/Housing-Development/Affordable-Housing-Production-by-Building/hg8x-zxpr)"),
                     tags$li(style = "font-size: 20px", "NYC Open data: Housing Maintenance Code Complaints (https://data.cityofnewyork.us/Housing-Development/Housing-Maintenance-Code-Complaints/uwyv-629c)"),
                   )
          ),
          
          tags$div(class = "user-guide-header", "Authors"),
          
          tags$div(class = "user-guide-text", 
                   tags$ul(
                     tags$li(style = "font-size: 20px", "Qingyang Tang"),
                     tags$li(style = "font-size: 20px", "Zixun Zhang"),
                     tags$li(style = "font-size: 20px", "Yi Xuan Qi"),
                     tags$li(style = "font-size: 20px", "Yuanxi Li"),
                     tags$li(style = "font-size: 20px", "Xiaoxue Ren"),
                     tags$li(style = "font-size: 20px", "Zhi Huang")
                   )
          )
        )) # appendix
        
      )   #item
    ) # dashboardBody
  )  #dashboardPage
)
