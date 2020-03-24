# author: Daniel Hadley
# date: March 13, 2020

.PHONY: all clean

all: docs/final_report.html docs/final_report.pdf

# Download data
data/raw_listings.csv : scripts/load.R
	Rscript scripts/load.R --data_url=https://raw.githubusercontent.com/STAT547-UBC-2019-20/data_sets/master/listings-Barcelona.csv

# Clean/Process data
data/clean_listings.csv : scripts/process.R data/raw_listings.csv
	Rscript scripts/process.R --path_raw=data/raw_listings.csv --path_clean=data/clean_listings.csv

# EDA
images/correlogram.png images/density_plot.png images/biolin_plot.png : scripts/EDA.R data/clean_listings.csv
	Rscript scripts/EDA.R --path_clean=data/clean_listings.csv --path_image=images/
	
# Linear Regression
images/lm1-QQPlot.png images/lm2-QQPlot.png data/lm1_results.rds data/lm2_results.rds : scripts/lm.R data/clean_listings.csv
	Rscript scripts/lm.R --path_data=data/clean_listings.csv

# Knit report
docs/final_report.html docs/final_report.pdf : docs/final_report.Rmd images/correlogram.png images/density_plot.png images/violin_plot.png images/lm1-QQPlot.png images/lm2-QQPlot.png
	Rscript scripts/knit.R --final_report="docs/final_report.Rmd"

# clean/remove intermediate data
clean : 
	rm -f data/*.csv
	rm -f data/*.rds
	rm -f images/*.png
	rm -f docs/*.tex
	rm -f docs/*.html
	rm -f docs/*.pdf
