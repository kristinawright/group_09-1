# author: Kristina Wright
# date: 2020-03-06
# edited by: Daniel Hadley
# edit date: 2020-03-13

"This script creates price density plots (density vs. listing price per night), 
a correllogram (longitude, price, minimum stay, review number, host listings number),
and a violin plot (price vs. district) for exploratory data analysis and saves them as 
seperate png files from cleaned data. This script takes in clean data CSV file path and 
image directory path where plots will be exported as the variable arguments.

Usage: exploratory_data_analysis.R --path_clean=<path_clean> --path_image=<path_image>" -> doc

## Load Libraries ####
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(corrplot)) # used to make correlogram plot
suppressPackageStartupMessages(library(gridExtra)) #used to arrange plots with grid.arrange()
suppressPackageStartupMessages(library(docopt))
suppressPackageStartupMessages(library(glue))

opt <- docopt(doc) # This is where the "Usage" gets converted into code that allows you to use commandline arguments

## Main Function Call ####
# saves plot images  
main <- function(path_clean, path_image){
  
  clean.dat <- load_clean(path_clean)
  
  density_plot(clean.dat)   
  ggsave('density_plot.png', width = 8, height = 5, path = path_image)
  
  
  png(glue(path_image, "/correlogram.png"), width = 5, height = 5, units = "in", res = 200)
  correlogram(clean.dat)
  dev.off()
  
  mean.price <- mean_price(clean.dat)
  
  violin_plot(clean.dat, mean.price)
  ggsave('violin_plot.png', width = 8, height = 5, path = path_image)
  
  print(glue("The exploratory data analysis has been successfully completed on {path_clean}! Plot images have been saved to {path_image}."))
}

## Define Functions Used in main() ####
#' Load clean data
#' This function loads in the clean/processed data
#' @param path_clean is the full path name to the clean data file
#' @examples
#' load_clean(https://raw.githubusercontent.com/STAT547-UBC-2019-20/group_09/master/data/clean_listings.csv)
load_clean <- function(path_clean) {
  #Use col_types=cols() to suppress output of column type guessing
  read_csv(file=path_clean, 
           col_types=cols())
}


#' Density plot
#' This function creates price density plot (density vs. listing price per night) for listings 
#' @param df specifies the name of the data frame which should correspond to the clean data
#' @examples
#' density_plota(clean.dat)
density_plot <- function(df) {
  df %>% 
    ggplot(aes(x=price)) + 
    geom_density() +
    theme_bw(14) +
    theme(plot.title = element_text(size = 11)) +
    ggtitle(label="Price Density for All Listings") +
    scale_x_continuous("Listing Price per Night", labels=scales::dollar_format(suffix="\u20AC", prefix='')) +
    ylab("Density")
}

#' Numerical data
#' This function selects numerical values from dataframe only to be used in correlogram and calculates the correlation against all columns
#' @param df  specifies the name of the data frame which should correspond to the clean data
#' @example
#' correlogram(clean.dat)
correlogram <- function(df){
  df %>%
    select(latitude,
           longitude,
           price,
           min_stay,
           reviews,
           host_listings) %>%
    cor() %>%
    corrplot(type="upper", 
             method="color", # colour scale plot
             tl.srt=45, #text angled for better viewing
             addCoef.col = "black", # Add correlation coefficient
             diag = FALSE,
             title="Correlation of Some Columns",
             mar=c(0,0,1,0)) # Correctly positions Title of Correlogram
}


#' Mean price 
#' This function calculates the mean price of the listings in each district for the violin plot
#' @param df  specifies the name of the data frame which should correspond to the clean data
#' @example
#' mean_price(clean.dat)
mean_price <- function(df){
  df %>% 
    # calculate the mean price for each district for plot ordering
      group_by(district) %>%
      summarize(mean = mean(price)) %>%
      arrange(desc(mean)) # mean price in descending order
}

#' Violin plot
#' This function creates a violin plot (price vs. district)
#' @param df  specifies the name of the data frame which should correspond to the clean data
#' @example
#' violin_plot(clean.dat, mean.price)
violin_plot <- function(df, mean.price){
 df%>%
  filter(price != 0) %>% # remove price = 0 
  mutate(district = factor(district, levels = unique(mean.price$district))) %>% #factor district by descending mean price
  ggplot(aes(district, price)) +
  geom_violin(stat = "ydensity") +
  scale_y_log10() +  # change to log10 scale since density of price is scewed
  ylab("Price (€)") +
  xlab("District") +
  ggtitle("Distribution of Price for Each Barcelona District") +
  theme_bw(15) +
  theme(plot.title = element_text(size = 14), axis.text.x = element_text(angle = 60, hjust = 1)) 
}

### tests

main(opt$path_clean, opt$path_image)
