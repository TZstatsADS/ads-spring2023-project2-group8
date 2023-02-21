#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
###############################Install Related Packages #######################
if (!require("shiny")) {
    install.packages("shiny")
    library(shiny)
}
if (!require("leaflet")) {
    install.packages("leaflet")
    library(leaflet)
}
if (!require("leaflet.extras")) {
    install.packages("leaflet.extras")
    library(leaflet.extras)
}
if (!require("dplyr")) {
    install.packages("dplyr")
    library(dplyr)
}
if (!require("magrittr")) {
    install.packages("magrittr")
    library(magrittr)
}
if (!require("mapview")) {
    install.packages("mapview")
    library(mapview)
}
if (!require("leafsync")) {
    install.packages("leafsync")
    library(leafsync)
}

if (!require("ggplot2")) {
  install.packages("ggplot2")
  library(ggplot2)
}
if (!require("hrbrthemes")) {
  install.packages("hrbrthemes")
  library(hrbrthemes)
}

if (!require("jsonlite")) {
  install.packages("jsonlite")
  library(jsonlite)
}

if (!require("tidyr")) {
  install.packages("tidyr")
  library(tidyr)
}

# load processed data

#data processing - some done in Lib r script
unit_data = read.csv("../out/units_cleaned.csv")

year_finished_days_df = read.csv("../out/year_finished_days_df.csv")
year_complaint_df = read.csv("../out/year_complaint_df.csv")
year_finished_rate_df = read.csv("../out/year_finished_rate_df.csv")
year_borough_complaint_df = read.csv("../out/year_borough_complaint_df.csv")
year_borough_finished_rate_df = read.csv("../out/year_borough_finished_rate_df.csv")
year_BoroughID_finished_days_df = read.csv("../out/year_BoroughID_finished_days_df.csv")
pre_covid_df <- read.csv('../out/pre_covid_df.csv')
covid_df <- read.csv('../out/covid_df.csv')

df<-read.csv("../data/Affordable_Housing_Production_by_Building.csv")
data<-df %>% drop_na(Longitude)
data<-data %>% drop_na(Latitude)
data = data %>% select(Project.ID, Project.Name, Project.Start.Date, Borough, Latitude, Longitude, Extremely.Low.Income.Units, Very.Low.Income.Units, Low.Income.Units, Moderate.Income.Units, Middle.Income.Units, Other.Income.Units)

borough = unique(data$Borough)
income_level = c('Extremely.Low.Income.Units', 'Very.Low.Income.Units', 'Low.Income.Units', 'Moderate.Income.Units', 'Middle.Income.Units', 'Other.Income.Units')


shinyServer(function(input, output) {
    #map
    output$group1_map <- renderLeaflet({
        Year <- input$group1_year
        Unit <- input$group1_unit
        unit_data %>% 
            dplyr::select("Start.Year", "Latitude", "Longitude", {{Unit}}) %>% 
            dplyr::filter(Start.Year == Year) %>% 
            leaflet() %>% 
            addTiles() %>% 
            addCircleMarkers(lng = ~Longitude, lat = ~Latitude, clusterOptions = markerClusterOptions())
    })
    
    # maintaines line plot
    output$line_plot1 <- renderPlot({
      # Filter the data based on the selected borough
      if (input$checkGroup == 0) {
        # No filtering, show all data
        plot_data <- year_complaint_df
      } else {
        # Filter by selected borough
        plot_data <- year_borough_complaint_df[year_borough_complaint_df$BoroughID == input$checkGroup, ]
      }
      
      # Create the plot
      ggplot(plot_data, aes(x = year, y = n)) +
        geom_line(color="grey") +
        geom_point(shape=21, color="black", fill="#d14115", size=6) +
        theme_ipsum() +
        labs(x = "Year", y = "Number of Complaints", title = "Number of complaints by Year")
    })
    output$line_plot2 <- renderPlot({
      # Filter the data based on the selected borough
      if (input$checkGroup == 0) {
        # No filtering, show all data
        plot_data <- year_finished_rate_df
      } else {
        # Filter by selected borough
        plot_data <- year_borough_finished_rate_df[year_borough_finished_rate_df$BoroughID == input$checkGroup, ]
      }

      # Create the plot
      ggplot(plot_data, aes(x = years, y = finished_rate)) +
        geom_line(color="grey") +
        geom_point(shape=21, color="black", fill="#15b2d1", size=6) +
        theme_ipsum() +
        labs(x = "Year", y = "Finished rate", title = "Finished rate by Year")
    })
    output$line_plot3 <- renderPlot({
      # Filter the data based on the selected borough
      if (input$checkGroup == 0) {
        # No filtering, show all data
        plot_data <- year_finished_days_df
      } else {
        # Filter by selected borough
        plot_data <- year_BoroughID_finished_days_df[year_BoroughID_finished_days_df$BoroughID == input$checkGroup, ]
      }
      # Create the plot
      ggplot(plot_data, aes(x=year, y=mean_days)) +
        geom_line(color="grey") +
        geom_point(shape=21, color="black", fill="#69b3a2", size=6) +
        theme_ipsum() +
        labs(x = "Year", y = "Average days to finish a complaint", title = "Average finish days by year")
    }) 
    
    output$left_map <- renderLeaflet({
      pre_covid_df %>%
        leaflet(options = leafletOptions(minZoom = 11, maxZoom = 13)) %>%
        addProviderTiles("CartoDB.Positron",options = providerTileOptions(noWrap = TRUE)) %>%
        setView(-73.9834,40.7504,zoom = 12) %>%
        addCircles(
          lng=pre_covid_df$lon,
          lat=pre_covid_df$lat,
          radius=pre_covid_df$totalcount)
    }) #left map plot
    
    output$right_map <- renderLeaflet({
      covid_df %>%
        leaflet(options = leafletOptions(minZoom = 11, maxZoom = 13)) %>%
        addProviderTiles("CartoDB.Positron",options = providerTileOptions(noWrap = TRUE)) %>%
        setView(-73.9834,40.7504,zoom = 12) %>%
        addCircles(
          lng=covid_df$lon,
          lat=covid_df$lat,
          radius=covid_df$totalcount)
    }) #right map plot
    
    # income level trend
    output$timePlot <- renderPlot({
      tf = input$timefrom
      tt = input$timeto
      bs = input$base
      bor = input$bor_type
      
      start_date = as.numeric(tf)
      end_date = as.numeric(tt)
      
      if (bs == 'Extremely.Low.Income.Units'){
        data_select = data[!(data$Extremely.Low.Income.Units == "0"), ]
      } else if (bs == 'Very.Low.Income.Units'){
        data_select = data[!(data$Very.Low.Income.Units == "0"), ]
      } else if (bs == 'Low.Income.Units'){
        data_select = data[!(data$Low.Income.Units == "0"), ]
      } else if (bs == 'Moderate.Income.Units'){
        data_select = data[!(data$Moderate.Income.Units == "0"), ]
      } else if (bs == 'Middle.Income.Units'){
        data_select = data[!(data$Middle.Income.Units == "0"), ]
      } else if (bs == 'Other.Income.Units'){
        data_select = data[!(data$Other.Income.Units == "0"), ]
      }
      
      data_select$Project.Start.Date <- as.Date(data_select$Project.Start.Date, "%m/%d/%Y")
      df2 <- data.frame(Project.Start.Date = data_select$Project.Start.Date,
                        year = as.numeric(format(data_select$Project.Start.Date, format = "%Y")))
      df2 <- df2[!duplicated(df2), ]
      data_select <- merge(data_select, df2, by="Project.Start.Date")
      data_select <- data_select %>% filter(year >= start_date) %>% filter(year <= end_date)
      
      if (bs == 'Extremely.Low.Income.Units'){
        temp <- data_select[(data_select$Borough == bor), ] %>% group_by(year) %>% 
          summarise(sum_Units=sum(Extremely.Low.Income.Units),
                    .groups = 'drop') %>% as.data.frame()
      } else if (bs == 'Very.Low.Income.Units'){
        temp <- data_select[(data_select$Borough == bor), ] %>% group_by(year) %>% 
          summarise(sum_Units=sum(Very.Low.Income.Units),
                    .groups = 'drop') %>% as.data.frame()
      } else if (bs == 'Low.Income.Units'){
        temp <- data_select[(data_select$Borough == bor), ] %>% group_by(year) %>% 
          summarise(sum_Units=sum(Low.Income.Units),
                    .groups = 'drop') %>% as.data.frame()
      } else if (bs == 'Moderate.Income.Units'){
        temp <- data_select[(data_select$Borough == bor), ] %>% group_by(year) %>% 
          summarise(sum_Units=sum(Moderate.Income.Units),
                    .groups = 'drop') %>% as.data.frame()
      } else if (bs == 'Middle.Income.Units'){
        temp <- data_select[(data_select$Borough == bor), ] %>% group_by(year) %>% 
          summarise(sum_Units=sum(Middle.Income.Units),
                    .groups = 'drop') %>% as.data.frame()
      } else if (bs == 'Other.Income.Units'){
        temp <- data_select[(data_select$Borough == bor), ] %>% group_by(year) %>% 
          summarise(sum_Units=sum(Other.Income.Units),
                    .groups = 'drop') %>% as.data.frame()
      }
      
      plot(temp$year,temp$sum_Units,xlab='Year', ylab='sum of units',main= paste0("Number of ", bs, ' in ', bor))
      lines(temp$year,temp$sum_Units)
    })
    
})