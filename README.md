# Group 09
Repository for Kristina Wright and Daniel Hadley group project for [STAT 547M](https://stat545.stat.ubc.ca/)

## 1. About This Repository :information_source:
> This repository houses Group 09's project for STAT 547M taken in Term 2 of the 2019-2020 academic here.
>
> Our project uses an Airbnb dataset to try and find significant factors to explain the listing prices (per night) in Barcelona, Spain.
>
> The final report is created by meeting milestones which are linked below.

## 2. Navigating the Repository :file_folder:
> As milestones are met, files are placed into the appropriate subfolders. 

1. The [data](https://github.com/STAT547-UBC-2019-20/group_09/tree/master/data) folder contains all datasets used throughout the project.
1. The [docs](https://github.com/STAT547-UBC-2019-20/group_09/tree/master/docs) folder contains all `*.Rmd` files used to create reports.
1. The [images](https://github.com/STAT547-UBC-2019-20/group_09/tree/master/images) folder saves all images produced for the group project.
1. The [scripts](https://github.com/STAT547-UBC-2019-20/group_09/tree/master/scripts) folder saves all `R` scripts (`*.r`) that are called when rendering the project.
1. The [tests](https://github.com/STAT547-UBC-2019-20/group_09/tree/master/tests) folder contains all tests carried out when producing the analysis.

| Milestone | Due Date :date: | Report
| :--: | ---- | :--------------: |
| [01](https://stat545.stat.ubc.ca/evaluation/milestone_01/milestone_01/) | February 29, 2020 | [milestone01](https://stat547-ubc-2019-20.github.io/group_09/docs/milestone01.html) |
| [02](https://stat545.stat.ubc.ca/evaluation/milestone_02/milestone_02/) | March 7, 2020 | :question: |

## 3. Usage :computer:

1. Clone this repo.

1. Ensure the following `R` packages are installed:

  - `ggplot2`
  - `tidyverse`
  - `here`
  - `docopt`
  - `knitr`
  - `DT`
  - `gridExtra`
  - `corrplot`
  - `glue`
  
1. Run the following scripts (in order) with the specified arguments:

  # Load data
  `Rscript scripts/load_data.r --data_url=https://raw.githubusercontent.com/STAT547-UBC-2019-20/data_sets/master/listings-Barcelona.csv`
  
  # Clean data
  `Rscript scripts/process_data.r --path_raw=data/raw_listings.csv --path_clean=data/clean_listings.csv`