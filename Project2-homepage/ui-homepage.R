library(shiny)
library(shinythemes)

ui <- fluidPage(
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
             tags$li(style = "font-size: 20px", "Income level: The trend of NYC housing for different income levels"),
             tags$li(style = "font-size: 20px", "Number of Bedrooms: The trend of NYC housing with different number of bedrooms"),
             tags$li(style = "font-size: 20px", "Housing maintenance: The trend of NYC housing maintenance performance"),
             tags$li(style = "font-size: 20px", "Appendix: Data source, authors, and other statements")
           )
  )
)

