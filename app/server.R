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

# load processed data

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
    
})