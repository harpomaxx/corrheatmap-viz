# Given a CSV file, calculate the correlation matrix and plot it in a heatmap

library(shiny)
library(d3heatmap)
library(caret)
data("airquality")

options(shiny.maxRequestSize = 30 * 1024 ^ 2)
shinyServer(function(input, output) {

  # Load a CSV file or a default dataset
  get_data <- reactive({
    if (is.null(input$file1))
      data = airquality
    else {
      data = read.csv(input$file1$datapath)
    }
    return(data)
  })
  
  # Convert factor to numbers
  numerize_factors <- reactive({
    data = get_data()
    if (TRUE %in% sapply(data, is.factor)) {
      data = sapply(data, as.numeric)
    }
    return(data) 
  })
  
  # Preproceses
  get_data_filtered <- reactive({
   
    data_filtered = numerize_factors() 
    if (input$regfilter != "")
      data_filtered = data_filtered[, grep(input$regfilter,
                                           names(data_filtered),
                                           invert = T,
                                           value = F)]
    return(data_filtered)
  })
  
  # Create Correlation Matrix
  get_corr_matrix <- reactive({
    data_filtered = get_data_filtered()
    corr_matrix <- cor(data_filtered,use = "na")
    data_lowcorr = data_filtered
    highcorr_predictors = findCorrelation(corr_matrix, cutoff = input$corrvalue /
                                              100.0)
    if (length(highcorr_predictors)>0)
          data_lowcorr = data_filtered[,-highcorr_predictors]
    corr_matrix = cor(data_lowcorr,use = "na")
    return(corr_matrix)
  })
  
  # Provide some information about the Correlation Matrix
  output$heatmaptitle <- renderText ({
    if (is.null(input$file1))
      msg = "Not file loaded. Showing Airquality dataset correlation matrix."
    else{
      msg = paste(
        "Filename: ",
        input$file1$name,
        br(),
        "Matrix dimensions: ",
        ncol(get_corr_matrix()),
        "x",
        ncol(get_corr_matrix()),
        "<BR>Matrix size in Mb: ",
        object.size(get_corr_matrix()) / 1024
      )
      data = get_data()
      if (TRUE %in% sapply(data, is.factor))
        msg = paste(msg,
                    br(),span(style="color:red",
                    "Warning: some factor variables were converted to numbers"))
    }
    return(msg)
    
  })
  output$heatmap <- renderD3heatmap({
    corr_matrix <- get_corr_matrix()
    d3heatmap(corr_matrix, anim_duration = 0)
  })
  
})
