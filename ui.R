
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(d3heatmap)
shinyUI(fluidPage(
 
  # Application title
  titlePanel("Heatmap Correlation Matrix"),

  sidebarLayout(
    sidebarPanel(
      
      fileInput('file1', 'Choose CSV File',
                accept=c('text/csv', 
                         'text/comma-separated-values,text/plain', 
                         '.csv')),
      

    
    sliderInput('corrvalue',label = h5("Select the correlation cutoff"),
                  min = 1, max = 100,value=90),
    
    textInput('regfilter', label = h5("Select Features to remove. Use regex like feature1|feature2|feature3"),value = NULL)
    ),
    
    
    # Show a plot of the generated distribution
    mainPanel(
      h5(htmlOutput("heatmaptitle")),
      d3heatmapOutput("heatmap")
    )
  )

  
  ))
