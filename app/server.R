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

# load processed data

#data processing


unit_data = read.csv("../out/units_cleaned.csv")

year_finished_days_df = read.csv("../out/year_finished_days_df.csv")
year_complaint_df = read.csv("../out/year_complaint_df.csv")
year_finished_rate_df = read.csv("../out/year_finished_rate_df.csv")
year_borough_complaint_df = read.csv("../out/year_borough_complaint_df.csv")
year_borough_finished_rate_df = read.csv("../out/year_borough_finished_rate_df.csv")
year_BoroughID_finished_days_df = read.csv("../out/year_BoroughID_finished_days_df.csv")

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
    
    
})