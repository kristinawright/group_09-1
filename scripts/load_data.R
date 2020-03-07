# author: Daniel Hadley
# date: 2020-03-06

## Documentation of script
"This script takes a required argument, data_url, that is a URL for the raw version of a *.csv dataset. That dataset is loaded R and saved in the data directory. This script loads the following R libraries: readr, docopt, here, glue.

Usage: load_data.R --data_url=<data_url>
" -> doc #documentation

## Load libraries ####
library(readr) #to use the read_csv() and write_csv() functions
library(docopt) #to allow command-line arguments
library(here) #to specify target directory to save file
library(glue) #to use glue() function to print message

opt <- docopt(doc) #The usage character is put into the docopt function which allows positional arguments in the script

## Main Function ####
## Since main() is not called yet, we can define other functions below the main function
main <- function(data_url){
  
  rslt <- load_url_data(data_url)
  
  print(glue("The dataset was successfully loaded from {data_url} and saved as {rslt$PATH}"))
}

## Define functions used in main() ####
#' 
#' @param data_url is a character string for the URL of the dataset
#' @examples
#' load_url_data(https://raw.githubusercontent.com/STAT547-UBC-2019-20/data_sets/master/listings-Barcelona.csv)
load_url_data <- function (data_url) { 
  ## Load data from URL
  dat.url <- read_csv(file=data_url)
  
  ## Create target directory
  target.dir <- here::here("data", "raw_listings.csv")
  
  ## Save URL data to target directory
  write_csv(x=dat.url, 
            path=target.dir)
  
  ## Print URL and Target Directory
  list('URL'=dat.url, 'PATH'=target.dir)
  
}

## Tests ####

## Main Command ####
## opt$data_url takes the argument from the terminal command line
## and passes it to the function as data_url
main(opt$data_url)