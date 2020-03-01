---
title: "Milestone 01 - Group 09"
author: "Daniel Hadley, Kristina Wright"
date: "February 29, 2020"
always_allow_html: true
output: 
  html_document:
    keep_md: yes
    toc: true
    toc_float: true
editor_options: 
  chunk_output_type: console
---



## Airbnb Listings for Barcelona

### Introduction

Airbnb, Inc. is a company founded in 2008 that offers an online marketplace connecting people who offer lodging with people who require accomodations in that locale. The company does not own any of the listed properties and operates as a broker, collecting commissions once a lodging is booked. As a direct competitor to hotels, we are interested in how the users listing properties determine the price they charge.

When accomodations are offered through Airbnb, the person listing the property is called a host, and they must provide a variety of information about the listing including price, neighborhood, type of accommodations offered, and the minimum number of nights a guest must stay if they want to make a booking. In addition to information provided by the host, Airbnb collects and disseminates information about the listing which we use to perform our analysis.

The data is collected using public information compiled from the Airbnb website. Specific collection techniques are not specified, though the Inside Airbnb [website](http://insideairbnb.com/behind.html) states that it uses Open Source technologies such as D3, Boostrap, jQuery, etc. to collect the data and much code was "copied and pasted" from the internet. A major contributer to this code, [Tom Slee](http://tomslee.net/category/airbnb-data), described it as a "scrape" of the Airbnb website for each city.


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
# This chunk reads the csv data into R

## Specify filename using here::here() so it can be used by anyone
filename <- here::here("data", "listings-Barcelona.csv")

## column types are specified to avoid the printing of this message
## by the read_csv() function
col_types <- cols(
  id = col_double(),
  name = col_character(),
  host_id = col_double(),
  host_name = col_character(),
  neighbourhood_group = col_character(),
  neighbourhood = col_character(),
  latitude = col_double(),
  longitude = col_double(),
  room_type = col_character(),
  price = col_double(),
  minimum_nights = col_double(),
  number_of_reviews = col_double(),
  last_review = col_date(format = ""),
  reviews_per_month = col_double(),
  calculated_host_listings_count = col_double(),
  availability_365 = col_double()
)

## Read in dataset and call it df
df <- read_csv(file=filename, col_types=col_types)
```

#### Remove Unwanted Data

In this section, we remove columns from the dataset that should have no fundamental influence on listing price. This includes the short title of th listing (`name`), the name of the host(s) (`host_name`), and the availability of the listing over the next 365 days (`availability_365`). While there might end up being a relation between availability and price, since cheap listings for a desirable neighbourhood are likely to be booked, this relationship is backwards; we want to find factors that affect the listing price, not factors affected by the listing price. 


```r
## Remove three unwanted columns
df <- df %>% 
  select(-name,
         -host_name,
         -availability_365)
```

#### Rename Columns

Some of the column names are a little long, so we perform the following renamings:
  
  - `neighbourhood_group` is renamed to `district`
  
  - `minimum_nights` is renamed to `min_stay`
  
  - `number_of_reviews` is renamed to `reviews`
  
  - `calculated_host_listings_count` is renamed to `host_listings`
  

```r
## Code to rename columns
df <- df %>% 
  rename(district = neighbourhood_group,
         min_stay = minimum_nights,
         reviews = number_of_reviews,
         host_listings = calculated_host_listings_count)

## View changes
kable(head(df),
      caption="The first 6 rows of the Barcelona listings dataset after removing unwanted columns and renaming certain columns")
```



Table: The first 6 rows of the Barcelona listings dataset after removing unwanted columns and renaming certain columns

    id   host_id  district     neighbourhood                         latitude   longitude  room_type          price   min_stay   reviews  last_review    reviews_per_month   host_listings
------  --------  -----------  -----------------------------------  ---------  ----------  ----------------  ------  ---------  --------  ------------  ------------------  --------------
 18666     71615  Sant Martí   el Camp de l'Arpa del Clot            41.40889     2.18555  Entire home/apt      130          3         1  2015-10-10                  0.02              30
 18674     71615  Eixample     la Sagrada Família                    41.40420     2.17306  Entire home/apt       60          1        20  2019-10-19                  0.25              30
 23197     90417  Sant Martí   el Besòs i el Maresme                 41.41203     2.22114  Entire home/apt      210          3        51  2019-09-29                  0.48               2
 25786    108310  Gràcia       la Vila de Gràcia                     41.40145     2.15645  Private room          32          1       268  2019-11-06                  2.38               1
 31958    136853  Gràcia       el Camp d'en Grassot i Gràcia Nova    41.40950     2.15938  Entire home/apt       60          1       182  2019-10-16                  1.71              39
 32471    136853  Gràcia       el Camp d'en Grassot i Gràcia Nova    41.40928     2.16112  Entire home/apt       70          1        90  2019-11-05                  0.84              39


#### Price Density


```r
## We exclude price by placing an upper bound on listing price per night
## at the below quantile
p.lvl <- 0.975 #probability level
qtile <- quantile(df$price, probs=p.lvl) #quantile at designated probability level
```

A kernel density plot is presented for listing prices of all listings (on the left) and listings excluding the top 2.5% (on the right). We see that a few outliers extremely skews the density of all listings far to the right. Using the `R` functions, `mean()`, `quantile()`, and `max()`, respectively, we see that the mean listing price for all listings is 134.59, the 3rd quartile for all listings is 105, while the maximum listing price of all listings is 15000. 

As a result, we exclude the top 2.5% of listings. The maximum allowed listing price is the filtered dataset is 500. The filter eliminated 464 rows, so that the filtered tibble has 19964 observations.



```r
p1 <- df %>% 
  ggplot(aes(x=price)) + 
  geom_density() +
  theme_bw() +
  ggtitle(label="(a) Density for Prices of All Listings") +
  scale_x_continuous("Listing Price per Night", labels=scales::dollar_format(suffix="\u20AC", prefix='')) +
  ylab("Density")

p2 <- df %>% 
  filter(price <= quantile(df$price, probs=0.975)) %>% 
  ggplot(aes(x=price)) + 
  geom_density() +
  theme_bw() +
  ggtitle(label="(b) Density for Prices of All Listings") +
  scale_x_continuous("Listing Price per Night", labels=scales::dollar_format(suffix="\u20AC", prefix='')) +
  ylab("Density")

grid.arrange(p1, p2, nrow=1)
```

![Plot (a) presents the Kernel density of listing prices for Barcelona; Plot (b) presents the Kernel density of listing prices for Barcelona where the price per night is less than 500 euros](/Users/sunshine2.0/Desktop/STAT547/Project/group_09/group_09/milestone01/milestone01_files/price-density-1.png)

#### Correllogram

Based on the correllogram shown below there is little correlation between the 6 numerical variables presented. All positive correlations are in blue, and all negative correlations are in red.


```r
# take numerical values from df only into new dataframe dfcor
dfcor <- df %>%
  select(latitude,
         longitude,
         price,
         min_stay,
         reviews,
         host_listings)
# calculate the correlation of each column against all other columns
df_correlations <- cor(dfcor) 

# plot the correllogram with corrplot
corrplot(df_correlations, 
         type="full", 
         method="color", # colour scale plot
         tl.srt=45, #text angled for better viewing
         addCoef.col = "black", # Add correlation coefficient
         diag = FALSE)
```

![](/Users/sunshine2.0/Desktop/STAT547/Project/group_09/group_09/milestone01/milestone01_files/correllogram-1.png)<!-- -->

#### Violin Plot

The violin plot below shows the distribution of price in log10 scale for each district in descending order of average price. Based on the plot, Eixample has the highest priced and Nou Barris has the lowest priced listings.


```r
# calculate the mean price for each district for plot ordering
mean_price<-df%>%
  group_by(district) %>%
  summarize(mean = mean(price)) %>%
  arrange(desc(mean)) # mean price in descending order
  
q<-df%>%
  mutate(district = factor(district, levels = unique(mean_price$district))) %>% #factor district by descending mean price
  ggplot(aes(district, price)) +
  geom_violin(stat = "ydensity") +
  scale_y_log10() +  # change to log10 scale since density of price is scewed
  ylab("Price (€)") +
  xlab("District") +
  ggtitle("Distribution of Price for Each Barcelona District")

q + theme(axis.text.x = element_text(angle = 60, hjust = 1))  # x axis labels angled to view text clearly
```

![](/Users/sunshine2.0/Desktop/STAT547/Project/group_09/group_09/milestone01/milestone01_files/violin plot-1.png)<!-- -->

### Research Question

In this analysis, we determine which factors are significantly related to the price of a listing.

### Plan of Action

With our research question, the first goal is to determine which factors are most important to explaining list price and perform a linear regression analysis. This may require some data transformation, handling or removal of outliers, and removing incomplete observations.

### References

[Airbnb dataset](http://insideairbnb.com/get-the-data.html)
