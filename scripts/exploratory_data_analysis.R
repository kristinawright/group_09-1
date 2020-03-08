# author: Kristina Wright
# date: 2020-03-06

"This script creates price density plots (density vs. listing price per night), a correllogram (longitude, price, minimum stay, review number, host listings number), and a violin plot (price vs. district) for exploratory data analysis and saves them as seperate png files from cleaned data. This script takes in the path where the images will be exported as the variable argument.

Usage: exploratory_data_analysis.R --path_clean=<path_clean> --path_image=<path_image>
  " -> doc

## Load Libraries ####
library(tidyverse)
library(gridExtra)
library(corrplot)
library(docopt)

opt <- docopt(doc) # This is where the "Usage" gets converted into code that allows you to use commandline arguments

## Main Function Call ####
# saves images
main <- function(path_clean, path_image){
  
  clean.dat <- load_clean(path_clean)
  
  plot1 <- density_plot(clean.dat)
  
  plot2 <- correllogram(clean.dat)
  
  mean.price <- mean_price(clean.dat)
  
  plot3 <- violin_plot(clean.dat, mean.price)
  
  plots <- c(plot1, plot2, plot3)
  
   plots %>%
  map(ggsave(., width = 8, height = 5, path = glue::glue( path_image, ., ".csv")))
  
 print(glue("The exploratory data analysis has been successfully completed!"))
}

## Define Functions Used in main() ####
#' Load clean data
#' This function loads in the clean/processed data
#' @param path_clean is the full path name to the clean data file
#' @examples
#' load_clean(https://raw.githubusercontent.com/kristinawright/group_09-1/origin/branchybranch/data/clean_listings.csv)
load_clean <- function(path_clean) {
  #Use col_types=cols() to suppress output of column type guessing
  read_csv(file=path_clean, 
           col_types=cols())
}


#' Density plot
#' This function creates price density plot (density vs. listing price per night) for a) all listings 
#' @param df specifies the name of the data frame which should correspond to the clean data
#' @examples
#' density_plot(clean.dat)
density_plot <- function(df){
  df %>% 
    ggplot(aes(x=price)) + 
    geom_density() +
    theme_bw(14) +
    theme(plot.title = element_text(size = 12)) +
    ggtitle(label="(a) Price Density for All Listings") +
    scale_x_continuous("Listing Price per Night", labels=scales::dollar_format(suffix="\u20AC", prefix='')) +
    ylab("Density")
}

#' Numerical data
#' This function selects numerical values from dataframe only to be used in correllogram and calculates the correlation against all columns
#' @param df  specifies the name of the data frame which should correspond to the clean data
#' @example
#' correllogram(clean.dat)
correllogram <- function(df){
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
             diag = FALSE)
}


#' Violin plot
#' This function creates a violin plot (price vs. district)
#' @param df  specifies the name of the data frame which should correspond to the clean data
#' @example
#' mean_price(clean.dat)
mean_price <- function(df){
  df %>% 
    # calculate the mean price for each district for plot ordering
      group_by(district) %>%
      summarize(mean = mean(price)) %>%
      arrange(desc(mean))  # mean price in descending order
}

#' Violin plot
#' This function creates a violin plot (price vs. district)
#' @param df  specifies the name of the data frame which should correspond to the clean data
#' @example
#' violin_plot(clean.dat, mean.price)
violin_plot <- function(df, mean.price){
 df%>%
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
