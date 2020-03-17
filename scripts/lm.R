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
  #Load listings
  df <- load_data(path_data)
  
  #Run Regression without log transforming the response
  lm1 <- lin.mod(df, log=FALSE)
  
  #Run Regression with log transform of response
  lm2 <- lin.mod(df, log=TRUE)
  
  #Save QQ-Plot of residuals for both regressions
  lm.qqplot(lm1, lbl="QQ-Plot for Price")
  lm.qqplot(lm2, lbl="QQ-Plot for Log(Price)")
  
  #Save linear model objects
  save_lm_obj(lm1)
  save_lm_obj(lm2)

  #Print message upon successful completion
  print(glue("The linear model was successfully run. The linear model objects are saved as {here::here('data', 'lm1_results.rds')} and 
              {here::here('data', 'lm1_results.rds')}, and QQ-plots have been saved for each linear model as 
              {here::here('images', 'lm1-QQPlot.png')} and {here::here('images', 'lm2-QQPlot.png')}!"))
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
#' @param log is an optional logical argument that performs a natural logarithmic transformation 
#' of the response variable when log=TRUE. Default sets log=FALSE
#' @examples
#' lin.mod(clean_listings)
lin.mod <- function(df, log=FALSE) {
  #Log transform response when log=TRUE
  if (log) {
    lm.1 <- lm(log(price) ~ district + room_type + distance + reviews_per_month,
               data = df)
  # Do not perform log transform when log=FALSE (default)
  } else {
    lm.1 <- lm(price ~ district + room_type + distance + reviews_per_month,
             data=df)
  }
  return(lm.1)
}

#' Output QQ-Plot of Residuals
#' This function takes in a linear model object and outputs the QQ-plot of the standardized residuals
#' to the images directory
#' @param lm.obj specifies the linear model object of which to take the QQ-plot of the residuals
#' @param lbl takes a text string for the title of the plot and is QQ-Plot by default
#' @examples
#' lm.qqplot(lm.1)
lm.qqplot <- function(lm.obj, lbl="QQ-Plot"){
  # ggplot(lm.obj, aes(qqnorm(.stdresid)[[1]], .stdresid)) + 
  #   geom_point(na.rm=TRUE) +
  #   geom_abline(slope=1) + 
  #   xlab("Theoretical Quantiles") + 
  #   ylab("Standardized Residuals") + 
  #   ggtitle("Normal Q-Q") + 
  #   theme_bw(14)
  # ggsave('QQ_plot.png', width = 8, height = 5, path = here::here("images"))
  
  #Create filename from the name of the lm object
  fname <- deparse(substitute(lm.obj))
  #Standardize the residuals
  err <- scale(lm.obj$residuals)
  
  #Create QQ-Plot
  ggplot() +
    geom_qq(aes(sample=err)) +
    geom_abline(slope=1, intercept=0) +
    ggtitle(label=lbl) +
    theme_bw(14)
  ggsave(paste(fname, '-QQPlot.png', sep=''), width=8, height=5, path=here::here("images"))
}


#' Save linear model as an object
#' This function saves the linear model object 
#' @param lm.obj specifies the name of the linear model object to be saved
#' @param path_lm is the path where the linear model object is to be saved
#' @examples
#' save_data_as(clean_df, /Users/username/directory/sub-directory/filename.csv)
save_lm_obj <- function(lm.obj) {
  #Create filename from the name of the lm object
  fname <- deparse(substitute(lm.obj))
  
  #Save object
  saveRDS(lm.obj, file=here::here("data", paste(fname, "_results.rds", sep='')))
}

## Tests ####

## Main Command ####
## opt$path_data takes the argument from the terminal command line for the dataset
main(opt$path_data)