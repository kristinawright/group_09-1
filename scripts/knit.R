# author: Daniel Hadley
# date: 2020-03-13

## Documentation of Script
"This script knits the final report together.

Usage: scripts/knit.R --final_report=<final_report>" -> doc #Add to documentation

## Load Libraries ####
## Suppress messages from loading of libraries
suppressPackageStartupMessages(library(glue))
suppressPackageStartupMessages(library(docopt))

opt <- docopt(doc) #The usage character is put into the docopt function which allows positional arguments in the script

## Main Function Call ####
main <- function(final_report) {
  rmarkdown::render(final_report,
                     c("html_document", "pdf_document"))
  
  # Print success message
  print(glue("The final report has been successfully rendered as {final_report}.html and {final_report}.pdf!"))
}

## Tests ####

## Main Command ####
## opt$final_report takes the argument from the terminal command line for the directory path to the final report
main(opt$final_report)