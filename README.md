# A Correlation Matrix Heatmap Vizualization

A simple shiny app for vizualizing a dataset correlation matrix using an interactive heatmap. 
Useful for vizualizing datasets several variables.

## Basic Usage

Upload a CSV file and  the correlation matrix will be plotted using the [d3heatmap package](https://github.com/rstudio/d3heatmap).
A interactive heatmap implemenation with the following features:

- Highlight rows/columns by clicking axis labels
- Click and drag over colormap to zoom in (click on colormap to zoom out)

Data frames containing factors are automatically converted to numbers. Variables can be removed by setting a correlation **cutoff** (via *findCorrelation* function from caret package) or by writting
a regexp. 

You can find a working example at [shinyapps.io](https://harpomaxx.shinyapps.io/correlation-heatmap/)

