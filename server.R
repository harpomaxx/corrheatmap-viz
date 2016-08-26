
library(shiny)
library(d3heatmap)
library(caret)
data(PimaIndiansDiabetes)
# calculate correlation matrix
options(shiny.maxRequestSize = 30 * 1024 ^ 2)
shinyServer(function(input, output) {
  
  get_data <- reactive({
    if (is.null(input$file1))
      data = iris[,1:4]
    else
      data = read.csv(input$file1$datapath)
    
  })
  
  get_data_filtered<-reactive({
    data=get_data()
    if (input$regfilter==""){
        data_filtered=get_data()
    }
    else
       data_filtered = data[,grep(input$regfilter,names(data),invert = T,value = F)]  
  })
  
  get_corr_matrix <- reactive({
    data <-get_data()
    data_filtered=get_data_filtered()
    corr_matrix <- cor(data_filtered)
    if (input$corrvalue < 100) {
     highcorr_predictors = findCorrelation(corr_matrix, cutoff = input$corrvalue /
                                              100.0)
      data_lowcorr = data_filtered[, -highcorr_predictors]
    }else{
      data_lowcorr = data_filtered
    } 
    corr_matrix = cor(data_lowcorr)
  })
  output$heatmaptitle <- renderText ({
    if (is.null(input$file1))
      return("Not file loaded")
    else{
      paste("Filename: ",input$file1$name,"<BR>Matrix dimensions: ",ncol(get_corr_matrix()),"x",ncol(get_corr_matrix()),"<BR>Matrix size in Mb: ",object.size(get_corr_matrix())/1024)
    }  
  })
  output$heatmap <- renderD3heatmap({
    corr_matrix <-get_corr_matrix()
    d3heatmap(corr_matrix, anim_duration = 0)
    
  })
  
})
