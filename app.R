# author: Kristina Wright
# date: 2020-03-30

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
library(tidyverse)

# Load the data here
load_clean <- function(path_clean) {
  read_csv(file=path_clean, 
           col_types=cols())
}
path_clean <- "data/clean_listings.csv"
clean.dat <- load_clean(path_clean)


# Create the slider
max.price<-max(clean.dat$price)

slider<-dccRangeSlider(
  id='slider',
  min=0,
  max=max.price,
  step=1,
  value=list(0, max.price))

#Create the button 
logbutton <- dccRadioItems(
  id = 'yaxis-type',
  options = list(list(label = 'Linear', value = 'linear'),
                 list(label = 'Log', value = 'log')),
  value = 'linear'
)

# 1: violin plot

mean_price <- function(df){
  df %>% 
    # calculate the mean price for each district for plot ordering
    group_by(district) %>%
    summarize(mean = mean(price)) %>%
    arrange(desc(mean)) # mean price in descending order
}
mean.price <- mean_price(clean.dat)

violin_plot1 <- function(price.slider = c(0, max.price), scale = "linear"){
  
  df1<-clean.dat
  df1<- clean.dat %>%
    filter(clean.dat$price > price.slider[1]) %>%
    filter(price < price.slider[2])
  
  p1<-df1%>%
    filter(price != 0) %>% # remove price = 0
    mutate(district = factor(district, levels = unique(mean.price$district))) %>% #factor district by descending mean price
    ggplot(aes(district, price)) +
    geom_violin(stat = "ydensity") +
    ylab(paste("Price (", "\u20AC", ")", sep='')) +
    xlab("District") +
    ggtitle(paste0("Distribution of Price from ", price.slider[1], " to ", price.slider[2], " \u20AC for Each Barcelona District over time (Scale : ", scale,")")) +
    theme_bw(15) +
    theme(plot.title = element_text(size = 14), axis.text.x = element_text(angle = 60, hjust = 1)) 
  
  if (scale == 'log'){
    p1 <- p1 + scale_y_continuous(trans='log10')
  }
  
  ggplotly(p1)
  }



# Assign components to variables
heading_main = htmlH1('My Dash app :)')

graph_1 = dccGraph(id='violin1',figure = violin_plot1())


app <- Dash$new()

# Load the data here


app$layout(
	htmlDiv(
		list(
			 heading_main,
			 htmlLabel('Select price range :'),
			 htmlDiv(id='output-container-range-slider'),
			 slider,
			 htmlLabel('Select y scale : '),
			 logbutton,
			 graph_1
		)
	)
)

#app callbacks
app$callback(
  #update figure of gap-graph
  output=list(id = 'violin1', property='figure'),
  #based on values of components
  params=list(input(id = 'slider', property='value'),
              input(id = 'yaxis-type', property='value')),
  #this translates your list of params into function arguments
  function(price.sliderr, yaxis_scale) {
    violin_plot1(price.sliderr, yaxis_scale)
  })

app$callback(
  output(id = 'output-container-range-slider', property='children'),
  params=list(input(id='slider', property='value')),
  function(value) {
    paste0("You have selected ", value[1], " to ", value[2], " \u20AC") 
  })


app$run_server(debug=TRUE)