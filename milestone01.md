---
title: "Milestone 01 - Group 09"
author: "Daniel Hadley, Kristina Wright"
date: "February 29, 2020"
always_allow_html: true
output: 
  html_document:
    keep_md: yes
    toc: true
---



## Airbnb Listings for Barcelona, Spain

### Introduction

Airbnb, Inc. is a company founded in 2008 that offers an online marketplace connecting people who offer lodging with people who require accomodations in that locale. The company does not own any of the listed properties and operates as a broker, collecting commissions once a lodging is booked. As a direct competitor to hotels, we are interested in how the users listing properties determine the price they charge.

When accomodations are offered through Airbnb, the person listing the property is called a host, and they must provide a variety of information about the listing including price, neighborhood, type of accommodations offered, and the minimum number of nights a guest must stay if they want to make a booking. In addition to information provided by the host, Airbnb collects and disseminates information about the listing which we use to perform our analysis.


### Data Description

The [dataset](http://insideairbnb.com/get-the-data.html) used in this analysis is collected and offered by Inside Airbnb, an independent, non-commercial project started by Murray Cox and John Morris. Their goal is to allow people to see how Airbnb might be affecting the residential housing market. We use the summary data for listings, since it includes the data we are interested in exploring and is more manageable, size-wise, than the detailed listings data.

The data used in this analysis was compiled on November 9, 2019 and includes 20,428 Airbnb listings that travellers see when using the Airbnb website to find accommodations in Barcelona, Spain. The table below describes the available data for each listing in the dataset.

| Variable Name | Column Name | Type of Data | Description
|---|---|---|---|
| Listing ID | `id` | Categorical/Numeric | Numeric identifier unique to each listing |
| Name | `name` | Character | Short title for the listing provided by the host |
| Host ID | `host_id` | Categorical/Numeric | Numeric identifier for the host of the listing |
| Host Name | `host_name` | Categorical/String | Name of the host or hosts of the listing provided by the host(s) to Airbnb |
| Neighbourhood Group | `neighbourhood_group` | Categorical/String | Districts of Barcelona as determined by the coordinates of the listing and the city's definition of its districts; this data is not the data provided by the host |
| Neighbourhood | `neighbourhood` | Categorical/String | Neighbourhoods of Barcelona are smaller geographical areas than districts and are determined by the coordinates of the listing and compared to the city's boundaries of its neighbourhoods; this data is not the neighbourhood provided by the host |
| Latitude | `latitude` | Numeric | Latitude coordinates of the listing |
| Longitude | `longitude` | Numeric | Longitude coordinates of the listing |
| Type of Accommodation | `room_type` | Categorical/String | Type of accommodations specify whether the listing is for an entire home or apartment, a private room in a shared home or apartment, a hotel room, or a shared room |
| Price | `price` | Numeric | The price per night, in euros, to book a listing |
| Minimum Stay | `minimum_nights` | Numeric | The minimum number of nights that a guest must reserve in order to book a listing |
| Number of Reviews | `number_of_reviews` | Numeric | The number of reviews left by guests after their stay |
| Last Review | `last_review` | Date | The date of the last review left by a guest |
| Reviews per Month | `reviews_per_month` | Numeric | The number of reviews left by guests of a listing divided by the number of months the listing has been active |
| Number of Listings by Host | `calculated_host_listings_count` | Numeric | A count of the number of listings under the same Host Name |
| Availability | `availability_365` | Numeric | The number of days over the next 365 days that the listing can be booked by guests; calculated as 365 minus booked days minus days listing is unavailable as per the host |

### Exploring the Dataset


```r
# First we read in the dataset.
filename <- here::here("data", "listings-Barcelona.csv")
df <- read_csv(file=filename)
```

```
## Parsed with column specification:
## cols(
##   id = col_double(),
##   name = col_character(),
##   host_id = col_double(),
##   host_name = col_character(),
##   neighbourhood_group = col_character(),
##   neighbourhood = col_character(),
##   latitude = col_double(),
##   longitude = col_double(),
##   room_type = col_character(),
##   price = col_double(),
##   minimum_nights = col_double(),
##   number_of_reviews = col_double(),
##   last_review = col_date(format = ""),
##   reviews_per_month = col_double(),
##   calculated_host_listings_count = col_double(),
##   availability_365 = col_double()
## )
```

#### Correlations




#### Price Density



#### Proportional Bar Chart



### Research Question

In this analysis, we determine which factors are significantly related to the price of a listing.

### Plan of Action

With our research question, the first goal is to determine which factors are most important to explaining list price. This may require some data transformation, handling or removal of outliers, and removing incomplete observations.

### References

