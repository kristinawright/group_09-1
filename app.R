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
slider_options <-  data.frame("value" = 0:4, "labels" =c("Fair", "Good", "Very Good", "Premium", "Ideal"))
max.price<-max(clean.dat$price)

dccRangeSlider(
  marks = setNames(lapply(0:max.price, 
   paste(as.character(0:max.price), ("\u20AC")))),
  min = -5,
  max = 6,
  value = list(-3,4)
)

slider<-dccRangeSlider(
  min=0,
  max=4,
  id = "slider",
  marks = list(
    "0" = "Fair",
    "1" = "Good",
    "2" = "Very Good",
    "3" = "Premium",
    "4" = "Ideal"
  ),
  value= 4
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

violin_plot1 <- function(price.slider = c(0, max.price), mean.price){
  
  filter.clarity <- dropdown_options$labels[dropdown_options$value==price.slider]
  
  df1<-clean.dat
  df1<- clean.dat %>%
    filter(clean.dat$price %in% price.slider)
  
  p1<-df1%>%
    filter(price != 0) %>% # remove price = 0
    mutate(district = factor(district, levels = unique(mean.price$district))) %>% #factor district by descending mean price
    ggplot(aes(district, price)) +
    geom_violin(stat = "ydensity") +
    scale_y_log10() +  # change to log10 scale since density of price is scewed
    ylab(paste("Price (", "\u20AC", ")", sep='')) +
    xlab("District") +
    ggtitle(paste0("Distribution of Price from ", price.slider[1], " to ", price.slider[2], "for Each Barcelona District")) +
    theme_bw(15) +
    theme(plot.title = element_text(size = 14), axis.text.x = element_text(angle = 60, hjust = 1)) 
  
  ggplotly(p1)
  }



# Assign components to variables
heading_main = htmlH1('My Dash app :)')

graph_1 = dccGraph(id='violin1',figure = violin_plot1(clean.dat, mean.price))


app <- Dash$new()

# Load the data here


app$layout(
	htmlDiv(
		list(
			 heading_main,
			 graph_1
		)
	)
)

#app callbacks
app$callback(
  #update figure of gap-graph
  output=list(id = 'violin1', property='figure'),
  #based on values of components
  params=list(input(id = 'slider', property='value')),
  #this translates your list of params into function arguments
  function(price.sliderr) {
    make_plot2(price.sliderr)
  })

app$run_server(debug=TRUE)