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

unit_data = read.csv("../out/units_cleaned.csv")

# Define UI for application that draws a histogram
shinyUI(
  dashboardPage(
    skin = "black",
    
    dashboardHeader(
      title = tags$h1("NYC Housing Production", style = "font-size: 19px")
    ),
    
    dashboardSidebar(
      sidebarMenu(
        menuItem("Home", tabName = "Home", icon = icon("home")),
        menuItem("Group1", tabName = "Group1", icon = icon("map")),
        menuItem("Group2", tabName = "Group2", icon = icon("chart-line")),
        menuItem("Group3", tabName = "Group3", icon = icon("chart-line")),
        menuItem("Appendix", tabName = "Appendix", icon = icon("info"))
      )
    ),
    
    dashboardBody(
      tags$style(type="text/css",
                 ".shiny-output-error { visibility: hidden; }",
                 ".shiny-output-error:before { visibility: hidden; }"
      ),
      
      tabItems(
        
        tabItem(tabName = "Home",
                fluidPage(
                  titlePanel("This is Home "),
                  HTML("home"),
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
                  titlePanel("This is Group2 "),
                  HTML("group 2"),
                )
        ),  #Group 2
        
        
        tabItem(tabName = "Group3",
                fluidPage(
                  # Add custom styles and colors to the app
                  tags$head(tags$style(HTML("
    body {
      background-color: #f2f2f2;
    }

    .navbar {
      background-color: #004d40 !important;
      font-size: 20px;
    }

    .navbar-inverse .navbar-nav > li > a {
      color: #ffffff;
    }

    h1 {
      color: #004d40;
      font-size: 36px;
      text-align: center;
      margin-top: 50px;
      margin-bottom: 30px;
    }

    h3 {
      color: #004d40;
      font-size: 24px;
      margin-top: 20px;
      margin-bottom: 10px;
    }

    .form-group {
      margin-top: 20px;
      margin-bottom: 20px;
    }

    .btn-default {
      background-color: #004d40;
      border-color: #004d40;
      color: #ffffff;
      font-size: 16px;
    }

    .btn-default:hover {
      background-color: #ffffff;
      border-color: #004d40;
      color: #004d40;
      font-size: 16px;
    }

    .well {
      background-color: #f2f2f2;
      border-color: #004d40;
    }

    .well h3 {
      color: #004d40;
      font-size: 24px;
      margin-top: 0;
      margin-bottom: 20px;
    }

    .well hr {
      border-top: 1px solid #004d40;
      margin-top: 10px;
      margin-bottom: 10px;
    }
  "))),
                  
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
        
        tabItem(tabName = "Appendix", fluidPage(
          titlePanel("This is Appendix"),
          
          HTML("appendix"),
          
        )) # appendix
        
      )   #item
    ) # dashboardBody
  )  #dashboardPage
)
