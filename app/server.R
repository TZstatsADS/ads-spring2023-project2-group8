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

res = fromJSON('https://data.cityofnewyork.us/resource/uwyv-629c.json?$limit=2986310')
Housing_Maintenance_df = data.frame(res)
#add year to dataset
Housing_Maintenance_df$year=substr(Housing_Maintenance_df$ReceivedDate,7,10)

Housing_Maintenance_df$year=as.integer(Housing_Maintenance_df$year)

#Use data from 2014-2022
Housing_Maintenance_after2014_df= filter(Housing_Maintenance_df,year>=2014)

Housing_Maintenance_after2014_df= filter(Housing_Maintenance_after2014_df,year<2023)

#count complaints by year
year_complaint_df=Housing_Maintenance_after2014_df %>% count(year) #return a df with columns year and n (nummber of complaints)
years=year_complaint_df$year
num_of_complaints=year_complaint_df$n

#create a finished df
Housing_Maintenance_after2014_finished_df=filter(Housing_Maintenance_after2014_df,StatusID==2)

year_complaint_finished_df=Housing_Maintenance_after2014_finished_df %>% count(year)

num_of_finished_complaints=year_complaint_finished_df$n
finished_rate=num_of_finished_complaints/num_of_complaints

year_finished_rate_df=cbind(years,finished_rate)

# add finished_days
Housing_Maintenance_after2014_finished_df$ReceivedDate=as.Date(Housing_Maintenance_after2014_finished_df$ReceivedDate,"%m/%d/%Y")
Housing_Maintenance_after2014_finished_df$StatusDate=as.Date(Housing_Maintenance_after2014_finished_df$StatusDate,"%m/%d/%Y")

Housing_Maintenance_after2014_finished_df$finish_days=difftime(Housing_Maintenance_after2014_finished_df$StatusDate,Housing_Maintenance_after2014_finished_df$ReceivedDate,units = "days")

year_finished_days_df <- Housing_Maintenance_after2014_finished_df %>% group_by(year) %>% 
  summarise(mean_days=mean(finish_days),
            .groups = 'drop')  


unit_data = read.csv("../out/units_cleaned.csv")
shinyServer(function(input, output) {

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
    
    
    output$line_plot1 <- renderPlot({
      # Filter the data based on the selected borough
      if (input$checkGroup == 0) {
        # No filtering, show all data
        plot_data <- Housing_Maintenance_after2014_df
      } else {
        # Filter by selected borough
        plot_data <- Housing_Maintenance_after2014_df[Housing_Maintenance_after2014_df$BoroughID == input$checkGroup, ]
      }
      
      # Count the number of complaints by year
      year_complaint_df <- plot_data %>% count(year)
      
      # Create the plot
      ggplot(year_complaint_df, aes(x = year, y = n)) +
        geom_line(color="grey") +
        geom_point(shape=21, color="black", fill="#d14115", size=6) +
        theme_ipsum() +
        labs(x = "Year", y = "Number of Complaints", title = "Number of complaints by Year")
    })
    
    output$line_plot2 <- renderPlot({
      # Filter the data based on the selected borough
      if (input$checkGroup == 0) {
        # No filtering, show all data
        plot_data <- Housing_Maintenance_after2014_df
        plot_data_finished <- Housing_Maintenance_after2014_finished_df
      } else {
        # Filter by selected borough
        plot_data <- Housing_Maintenance_after2014_df[Housing_Maintenance_after2014_df$BoroughID == input$checkGroup, ]
        plot_data_finished <- Housing_Maintenance_after2014_finished_df[Housing_Maintenance_after2014_finished_df$BoroughID == input$checkGroup, ]
      }
      
      # Compute finished rate
      year_complaint_df <- plot_data %>% count(year)
      
      num_of_complaints <- year_complaint_df$n
      
      year_complaint_finished_df <- plot_data_finished %>% count(year)
      
      num_of_finished_complaints <- year_complaint_finished_df$n
      
      finished_rate <- num_of_finished_complaints / num_of_complaints
      
      years <- year_complaint_df$year
      
      year_finished_rate_df <- data.frame(years, finished_rate)
      
      # Create the plot
      ggplot(year_finished_rate_df, aes(x = years, y = finished_rate)) +
        geom_line(color="grey") +
        geom_point(shape=21, color="black", fill="#15b2d1", size=6) +
        theme_ipsum() +
        labs(x = "Year", y = "Finished rate", title = "Finished rate by Year")
    })
    
    
    output$line_plot3 <- renderPlot({
      # Filter the data based on the selected borough
      if (input$checkGroup == 0) {
        # No filtering, show all data
        plot_data <- Housing_Maintenance_after2014_finished_df
      } else {
        # Filter by selected borough
        plot_data <- Housing_Maintenance_after2014_finished_df[Housing_Maintenance_after2014_finished_df$BoroughID == input$checkGroup, ]
      }
      
      #compute finished dates
      plot_data$finish_days=difftime(plot_data$StatusDate,plot_data$ReceivedDate,units = "days")
      
      year_finished_days_df <- plot_data %>% group_by(year) %>% 
        summarise(mean_days=mean(finish_days),
                  .groups = 'drop')  
      
      # Create the plot
      ggplot(year_finished_days_df, aes(x=year, y=mean_days)) +
        geom_line(color="grey") +
        geom_point(shape=21, color="black", fill="#69b3a2", size=6) +
        theme_ipsum() +
        labs(x = "Year", y = "Average days to finish a complaint", title = "Average finish days by year")
    })    
})