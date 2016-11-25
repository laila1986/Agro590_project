library(shiny)
library(shinyTable)

server <- function(input, output, session) {
  
  rv <- reactiveValues(cachedTbl = NULL)
  
  output$tbl <- renderHtable({
    if (is.null(input$tbl)){
      
      #fill table with 0
      tbl <- matrix(0, nrow=3, ncol=3)
      
      rv$cachedTbl <<- tbl
      return(tbl)
    } else{
      rv$cachedTbl <<- input$tbl
      return(input$tbl)
    }
  })  
  
  output$tblNonEdit <- renderTable({
    
    #add dependence on button
    input$actionButtonID
    
    #isolate the cached table so it only responds when the button is pressed
    isolate({
      rv$cachedTbl
    })
  })    
}


ui <- shinyUI(pageWithSidebar(
  
  headerPanel("shinyTable with actionButton to apply changes"),
  
  sidebarPanel(
    helpText(HTML("A simple editable matrix with a functioning update button. 
                  Using actionButton not submitButton. 
                  Make changes to the upper table, press the button and they will appear in the lower. 
                  <p>Created using <a href = \"http://github.com/trestletech/shinyTable\">shinyTable</a>."))
  ),
  
  # Show the simple table
  mainPanel(
    #editable table
    htable("tbl"),
    #update button
    actionButton("actionButtonID","apply table edits"),
    #to show saved edits
    tableOutput("tblNonEdit")
  )
))

shinyApp(ui = ui, server = server)