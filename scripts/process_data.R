# author: Daniel Hadley
# date: 2020-03-06

## Documentation of Script
"This script loads the raw CSV file, cleans the data by removing unwanted columns, 
renaming columns with long names, limits price per night to the 97.5% quantile, 
and then saves the cleaned data as a new CSV file. 
The scripts one argument for the path to the raw data <path_raw> 
and the path to where we save the clean data <path_clean>. 
This script loads the R libraries: tidyverse, docopt.

Usage: clean_data.R --path_raw=<path_raw> --path_clean=<path_clean>
" -> doc

## Load Libraries ####
## Suppress messages from loading of libraries
suppressPackageStartupMessages(library(tidyverse)) # "shut up, tidyverse"
suppressPackageStartupMessages(library(glue))
library(docopt)

opt <- docopt(doc) #The usage character is put into the docopt function which allows positional arguments in the script

## Main Function Call ####
main <- function(path_raw, path_clean){
  clean.dat <- load_data(path_raw) %>% 
    remove_cols() %>% 
    rename_cols() %>% 
    price_filter()
  
  save_data_as(clean.dat, path_clean)
  print(glue("The raw data {path_raw} has been successfully cleaned and saved as {path_clean}!"))
}

## Define Functions Used in main() ####

#' Load data
#' This function loads in the raw data
#' @param path_raw is the full path name to the raw data file in the data folder
#' @examples
#' load_data(https://raw.githubusercontent.com/STAT547-UBC-2019-20/data_sets/master/listings-Barcelona.csv)
load_data <- function(path_raw) {
  #Use col_types=cols() to suppress output of column type guessing
  read_csv(file=path_raw, 
           col_types=cols())
}

#' Remove columns
#' This function removes columns not relevant to the project: name, host_name, availability_365
#' @param df specifies the name of the data frame which should correspond to the raw data
#' @examples
#' remove_columns(raw.dat)
remove_cols <- function(df){
  df %>% 
    select(-name,
           -host_name,
           -availability_365)
}

#' Rename columns
#' This function renames columns with long names: neighbourhood_group, minimum_nights, number_of_reviews, calculated_host_listings_count
#' to the respective name: district, min_stay, reviews, host_listings
#' @param df specifies the name of the data frame that contains the four columns to be renamed
#' @examples
#' rename_cols(raw.dat)
rename_cols <- function(df){
  df %>% 
    rename(district = neighbourhood_group,
           min_stay = minimum_nights,
           reviews = number_of_reviews,
           host_listings = calculated_host_listings_count)
}

#' Filter by Price
#' This function excludes price by placing an upper bound on listing price per night
#' @param df specifies the name of the data frame that contains a column named `price`
#' @examples
#' price_filter(dataframe.name)
price_filter <- function(df) {
  df %>% 
    filter(price <= quantile(df$price, probs=0.975))
}

#' Save cleaned data
#' This function saves the cleaned data to the specified path as a CSV file
#' @param df specifies the name of the data frame containing the cleaned/processed data
#' @param path_clean is the path where the cleaned data should be saved
#' @examples
#' save_data_as(clean_df, /Users/username/directory/sub-directory/filename.csv)
save_data_as <- function(df, path_clean) {
  write_csv(x=df, 
            path=path_clean)
}

## Tests ####

## Main Command ####
## opt$path_raw takes the argument from the terminal command line for the raw data path
## opt$path_clean takes the argument from the terminal command line where the cleaned data should be saved
main(opt$path_raw, opt$path_clean)