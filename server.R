
library(shiny)
library(d3heatmap)
library(caret)
options(shiny.maxRequestSize = 30 * 1024 ^ 2)
shinyServer(function(input, output) {
  output$heatmaptitle <- renderText({
    if (is.null(input$file1))
      return("Not file loaded")
    
    input$file1$name
    
  })
  output$heatmap <- renderD3heatmap({
    if (is.null(input$file1))
      return(NULL)
    
    data = read.csv(input$file1$datapath)
    corr_matrix = cor(data)
    if (input$corrvalue < 100) {
      highcorr_predictors = findCorrelation(corr_matrix, cutoff = input$corrvalue /
                                              100.0)
      data_reduced = data[, -highcorr_predictors]
      corr_matrix = cor(data_reduced)
    }
    d3heatmap(corr_matrix, anim_duration = 0)
    
  })
  
})
