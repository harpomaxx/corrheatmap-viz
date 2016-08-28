

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
      uiOutput("selectdataset"),
      fileInput('file1', ' Or upload a new CSV File (compressed files supported)',
                accept=c('text/csv', 
                         'text/comma-separated-values,text/plain', 
                         '.csv')),
    
    sliderInput('corrvalue',label = h5("Select the correlation cutoff"),
                  min = 1, max = 100,value=90),
    
    textInput('regfilter', label = h5("Select the features you want to remove. Use a regex like variable1|variable2|variable3"),value = NULL),
    
    h6("Source code available at ", a("github",href="https://github.com/harpomaxx/corrheatmap-viz/"))
     ),
    
    
    # Show a plot of the generated distribution
    mainPanel(
      h5(htmlOutput("heatmaptitle")),
      d3heatmapOutput("heatmap")
    )
  )

  
  ))
