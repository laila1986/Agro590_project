# Shiny app for data visualization ######

# Load packages #####################################################
require(tidyverse)
library(shinydashboard)

# Load data #########################################################
data <- readRDS("data/scenarios.rds")

# Source helper code ################################################
source("code/extract_keys.R")


ui <- dashboardPage(
  dashboardHeader(title = "FACTS"),
  dashboardSidebar(),
  dashboardBody(
    # Boxes need to be put in a row (or column)
    fluidRow(
      box(plotOutput("plot1", height = 250)),
      
      box(
        title = "Controls",
        sliderInput("slider", "Number of observations:", 1, 100, 50)
      )
    )
  )
)

server <- function(input, output) {
  set.seed(122)
  histdata <- rnorm(500)
  
  output$plot1 <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
  })
}

shinyApp(ui, server)