# Shiny app for data visualization ######

# Load packages #####################################################
require(tidyverse)
library(shinydashboard)

# Load data #########################################################
data <- readRDS("data/scenarios.rds")

# Source helper code ################################################
source("code/extract_keys.R")

# UI elements ###############################################################

# Header 
header <- dashboardHeader(
  title = "Pre-season Tool"
)

# Sidebar
sidebar <- dashboardSidebar(
  sidebarMenu(
    h3("Select crop"),
    menuItem("Corn", tabName = "Corn", icon = icon("leaf")),
    menuItem("Soybean", tabName = "Soybean", icon = icon("leaf"))
  )
)

# Body

body <- dashboardBody(
  # 
  p(
    class = "text-muted",
    paste("SOME TEXT HERE."
    )
  ),

  tabItems(
    # CORN TAB
    tabItem(tabName = "Corn",
            h2("Corn"),
              tabBox(title = "Create scenario", width = 12,
                     selected = "Site >",
                     tabPanel("Site >",radioButtons("select_corn_site", "",choices = as.character(cornKey$site),selected = "Ames")),
                     tabPanel("Climate >" ,radioButtons("select_corn_climate", "",choices = as.character(cornKey$climate),selected = "Average")),
                     tabPanel("Maturity >" ,radioButtons("select_corn_maturity", "Relative maturity",choices = as.character(cornKey$maturity),selected = "normal")),
                     tabPanel("Planting >" ,radioButtons("select_corn_planting", "Planting date (dd-mm)",choices = as.character(cornKey$planting),selected = "1-may")),
                     tabPanel("Initial Conditions >",
                              radioButtons("select_corn_previousCrop", "Previous crop",choices = as.character(cornKey$previousCrop),selected = "soy"),
                              radioButtons("select_corn_waterTable", "Water table depth (in)",choices =round(as.numeric(as.character(cornKey$waterTable))/25.4,0),selected = "40"),
                              radioButtons("select_corn_residualN", "Residual N (lb/a)",choices = round(as.numeric(as.character(cornKey$residualN))/1.12,0),selected = "17")
                     ),
                     tabPanel("N fertilizer >",
                              radioButtons("select_corn_Nrate", "Rate (lb N/a)",choices = round(as.numeric(as.character(cornKey$Nrate))/1.12,0),selected = "134"),
                              radioButtons("select_corn_Ntime", "Source and timing",choices = as.character(cornKey$Ntime),selected = "UAN injected at planting")),
                     tabPanel("Add Scenario",textInput("select_corn_scenarioName", "Type scenario name:" , "Home field"),
                              actionButton("add_botton", "Add scenario"),
                              actionButton("clearLast_botton", "Delete last"),
                              actionButton("clearAll_botton", "Clear all"))
                     ),
              box(width = 12,"Saved scenarios",
                  tableOutput("corn_scenarios")
                  ),
            fluidRow(
              column(width = 3,
                  box(width = NULL, status = "warning",
                      uiOutput("routeSelect"),
                      checkboxGroupInput("select_variables", "Show",
                                        choices = c(variables),
                                        selected = c(1:15)
                      ),
                      actionButton("variable_botton", "Update")
                     )
                  ),
              column( width = 9,
                  box(width = NULL, status = "warning",
                      uiOutput("routeSelect"),
                      checkboxGroupInput("select_variables", "Show",
                                         choices = c(variables),
                                         selected = c(1:15)
                      ),
                      actionButton("variable_botton", "Update")
                      )
                  )
              )
    ),
    
    # SOYBEAN TAB
    tabItem(tabName = "Soybean",
            h2("Soybean")
    )
  )
)


# UI

ui <- dashboardPage(
  header,
  sidebar,
  body,
  skin = "red"
)

# Server #############################################################

server <- function(input, output) {
  output$corn_scenarios <- renderTable(multiscenario_random(cornKey,3))
}

# Run app ############################################################

shinyApp(ui, server)