# author: Kristina Wright
# date: 2020-03-15

"This script is the main file that creates a Dash app.

Usage: app.R
"

# Libraries

library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(ggplot2)
library(plotly)
library(purrr)
library(tibble)


# Assign components to variables
heading_main = htmlH1('My Dash app :)')



app <- Dash$new()

# Load the data here


app$layout(
	htmlDiv(
		list(
			 heading_main
			 
		)
	)
)


app$run_server(debug=TRUE)