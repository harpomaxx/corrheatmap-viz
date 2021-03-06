# Given a CSV file, calculate the correlation matrix and plot it on a heatmap

library(shiny)
library(d3heatmap)
library(caret)

data_dir="data/"
options(shiny.maxRequestSize = 60 * 1024 ^ 2)
dataset_list=as.list(list.files(data_dir))

zeroVar <- function(dat) {
  out <- lapply(dat, function(x) length(unique(x)))
  want <- which(!out > 1)
  return(want)
}

shinyServer(function(input, output) {

  # Load a new CSV, save it locally and append it to dataset_list
  datachoices <-reactive({
    if (is.null(input$file1)==FALSE){
      new_data = read.csv(input$file1$datapath)
      write.csv(new_data, file=paste(data_dir,input$file1$name,sep=""),sep = ',')
      dataset_list=c(dataset_list,input$file1$name)
    }
    return(dataset_list)
  })
  get_data<- reactive({
    data = read.csv(paste(data_dir,input$dataset,sep=""))
    #remove zero variance predictors
    zero_var_predictors=zeroVar(data)
    if (length(zero_var_predictors)>0)
      data <-data[,-zero_var_predictors]
    return(data)
  })
  # Convert factor to numbers
  numerize_factors <- reactive({
    data = get_data()
    data_names=colnames(data) #save data_colnames for later
    if (TRUE %in% sapply(data, is.factor)) {
      data = sapply(data, as.numeric)
    }
    colnames(data) <- data_names
    return(data) 
  })
  
  # Preproceses
  get_data_filtered <- reactive({
   
    data_filtered = numerize_factors() 
    if (input$regfilter != "")
      data_filtered = data_filtered[, grep(input$regfilter,
                                           colnames(data_filtered),
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
      msg = paste(
        "Filename: ",
        input$dataset,
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
                    "Warning: some factor variables were found and converted to numbers"))
    return(msg)
    
  })
  output$heatmap <- renderD3heatmap({
    corr_matrix <- get_corr_matrix()
    d3heatmap(corr_matrix, anim_duration = 0,dendrogram= 'both',color="Reds")
  })
  
  output$selectdataset <- renderUI({
    selectInput("dataset", 
                label = "Choose a dataset to use",
                choices = datachoices(), selected = datachoices()[[length(datachoices())]]
    )
  })
})
