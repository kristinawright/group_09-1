# author: Daniel Hadley
# date: 2020-03-13

## Documentation of Script
"This script performs linear regression on the price of listings against
the independent variables district, room_type, reviews_per_month, and distance

Usage: clean_data.R --path_data=<path_data>" -> doc

## Load Libraries ####
## Suppress messages from loading of libraries
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(glue))
suppressPackageStartupMessages(library(docopt))

opt <- docopt(doc) #The usage character is put into the docopt function which allows positional arguments in the script

## Main Function Call ####
main <- function(path_data){
  #Run Regression
  lm1 <- load_data(path_data) %>% 
    lin.mod()
  
  #Save QQ-Plot of residuals
  lm.qqplot(lm1)
  
  #Save linear model object
  save_lm_obj(lm1)

  #Print message upon successful completion
  print(glue("The linear model was successfully run. The linear model object is saved as {here::here('data', 'lm_results')},
             and the residual QQ-plot has been saved as {here::here('images', 'QQ_plot.png')}!"))
}

## Define Functions Used in main() ####

#' Load data
#' This function loads in the data
#' @param path_data is the full path name to the data file in the data folder
#' @examples
#' load_data(data/clean_listings.csv)
load_data <- function(path_data) {
  #Use col_types=cols() to suppress output of column type guessing
  read_csv(file=path_data, 
           col_types=cols())
}

#' Perform Linear Regression
#' This function performs the linear regression of price ~ district + room_type + distance + reviews_per_month
#' @param df specifies the name of the data frame on which the regression is run
#' @examples
#' lin.mod(clean_listings)
lin.mod <- function(df){
  lm.1 <- lm(price ~ district + room_type + distance + reviews_per_month,
             data=df)
}

#' Output QQ-Plot of Residuals
#' This function takes in a linear model object and outputs the QQ-plot of the residuals
#' to the images directory
#' @param lm.obj specifies the linear model object of which to take the QQ-plot of the residuals
#' @examples
#' lm.qqplot(lm.1)
lm.qqplot <- function(lm.obj){
  ggplot(lm.obj, aes(qqnorm(.stdresid)[[1]], .stdresid)) + 
    geom_point(na.rm=TRUE) +
    geom_abline(slope=1) + 
    xlab("Theoretical Quantiles") + 
    ylab("Standardized Residuals") + 
    ggtitle("Normal Q-Q") + 
    theme_bw(14)
  ggsave('QQ_plot.png', width = 8, height = 5, path = here::here("images"))
}


#' Save linear model as an object
#' This function saves the linear model object 
#' @param lm.obj specifies the name of the linear model object to be saved
#' @param path_lm is the path where the linear model object is to be saved
#' @examples
#' save_data_as(clean_df, /Users/username/directory/sub-directory/filename.csv)
save_lm_obj <- function(lm.obj) {
  saveRDS(lm.obj, file=here::here("data", "lm_results"))
}

## Tests ####

## Main Command ####
## opt$path_data takes the argument from the terminal command line for the dataset
main(opt$path_data)