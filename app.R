# author: Kristina Wright
# date: 2020-03-30

"This script is the main file that creates a Dash app.

Usage: app.R
"

# Libraries

library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(ggplot2)
library(plotly)
library(purrr)
library(tibble)
library(tidyverse)
library(ggridges)

# Load the data here
load_clean <- function(path_clean) {
  read_csv(file=path_clean, 
           col_types=cols())
}
path_clean <- "data/clean_listings.csv"

clean.dat <- load_clean(path_clean)

mean_price <- function(df){
  df %>% 
    # calculate the mean price for each district for plot ordering
    group_by(district) %>%
    summarize(mean = mean(price)) %>%
    arrange(desc(mean)) # mean price in descending order
}
mean.price <- mean_price(clean.dat)

mean_price2 <- function(df){
  df %>% 
    # calculate the mean price for each district for plot ordering
    group_by(room_type) %>%
    summarize(mean = mean(price)) %>%
    arrange(desc(mean)) # mean price in descending order
}
mean.price2 <- mean_price2(clean.dat)

clean.dat <- clean.dat %>%
  mutate(district = factor(district, levels = unique(mean.price$district))) %>% #factor district by descending mean price
  mutate(room_type = factor(room_type, levels = unique(mean.price2$room_type))) #factor room_type by descending mean price


# Create the slider
max.price<-max(clean.dat$price)

slider<-dccRangeSlider(
  id='slider',
  min=0,
  max=max.price,
  step=1,
  value=list(0, max.price))

# Create the button 
logbutton <- dccRadioItems(
  id = 'yaxis-type',
  options = list(list(label = 'Linear', value = 'linear'),
                 list(label = 'Log', value = 'log')),
  value = 'linear'
)

# 1: Create the checklist
xaxisKey <- tibble(labels = as.character(levels(clean.dat$district)),
                   value = as.character(levels(clean.dat$district)))

checklist<- dccChecklist(
  id = "checklist",
  options = map(
    1:nrow(xaxisKey), function(i){
      list(label = xaxisKey$labels[i], value = xaxisKey$value[i])
    }),
  value=as.character(levels(clean.dat$district))
)

# 2: Create the checklist
xaxisKey2 <- tibble(labels = as.character(levels(clean.dat$room_type)),
                   value = as.character(levels(clean.dat$room_type))) 
xaxisKey2$labels[xaxisKey2$labels == "Entire home/apt"] <- "Entire home/apartment"

checklist2<- dccChecklist(
  id = "checklist2",
  options = map(
    1:nrow(xaxisKey2), function(i){
      list(label = xaxisKey2$labels[i], value = xaxisKey2$value[i])
    }),
  value=as.character(levels(clean.dat$room_type))
)

# 0: map

map_maker <- function(price.slider = c(0, max.price),  districtc = as.character(levels(clean.dat$district)),  room.typec = as.character(levels(clean.dat$room_type))){
  
  df0<-clean.dat
  df0<- clean.dat %>%
    filter(clean.dat$price >= price.slider[1]) %>%
    filter(price <= price.slider[2]) %>%
    filter(district %in% districtc) %>%
    filter(room_type %in% room.typec) 

  
  fig <- df0 
  fig <- fig %>%
    plot_ly(
      lat = ~latitude,
      lon = ~longitude,
      color = ~price, 
      alpha = 0.3,
      type = 'scattermapbox') 
  fig <- fig %>%
    layout(title = 'Barcelona Airbnb listings',
      mapbox = list(
        style = 'open-street-map',
        zoom =10.5,
        center = list(lon = ~median(longitude), lat = ~median(latitude))))
  fig
  
  
}

# 1: violin plot

violin_plot1 <- function(price.slider = c(0, max.price), scale = "linear", districtc = as.character(levels(clean.dat$district))){
  
  df1<-clean.dat
  df1<- clean.dat %>%
    filter(clean.dat$price >= price.slider[1]) %>%  # min
    filter(price <= price.slider[2]) %>%  # max
    filter(district %in% districtc) 
    
  p1<-df1%>%
    ggplot(aes(district, price,fill = stat(x))) +
    geom_violin(stat = "ydensity") +
    ylab(paste("Price (", "\u20AC", ")", sep='')) +
    xlab("District") +
    scale_fill_viridis_c(name = "District", option = "B") +
    ggtitle(paste0("Distribution of Price from ", price.slider[1], " to ", price.slider[2], " \u20AC by Barcelona District over time (Scale : ", scale,")")) +
    theme_bw(15) +
    theme(plot.title = element_text(size = 14), axis.text.x = element_text(angle = 60, hjust = 1),legend.position = "none") 

  
  if (scale == 'log'){
    p1 <- p1 + scale_y_continuous(trans='log10')
  }
  
  ggplotly(p1)
  }


# 2: violin plot

violin_plot2 <- function(price.slider = c(0, max.price), scale = "linear", room.typec = as.character(levels(clean.dat$room_type))){

  df2<-clean.dat
  df2<- clean.dat %>%
    filter(clean.dat$price >= price.slider[1]) %>%
    filter(price <= price.slider[2]) %>%
    filter(room_type %in% room.typec)


  p2<-df2%>%
    ggplot(aes(room_type, price, fill=stat(x))) +
    geom_violin(stat = "ydensity") +
    ylab(paste("Price (", "\u20AC", ")", sep='')) +
    xlab("Room Type") +
    scale_fill_viridis_c(name = "Room Type",option = "E") +
    ggtitle(paste0("Distribution of Price from ", price.slider[1], " to ", price.slider[2], " \u20AC by Room Type over time (Scale : ", scale,")")) +
    theme_bw(15) +
    theme(plot.title = element_text(size = 14), axis.text.x = element_text(angle = 60, hjust = 1),legend.position = "none")

  if (scale == 'log'){
    p2 <- p2 + scale_y_continuous(trans='log10')
  }

  ggplotly(p2)
}



# Assign components to variables
heading_main = htmlH1('Barcelona Airbnb Price App :)')

graph_0 = dccGraph(id='map',figure=map_maker()) 
graph_1 = dccGraph(id='violin1',figure = violin_plot1())
graph_2 = dccGraph(id='violin2',figure = violin_plot2())

text <- dccMarkdown("_
This app shows the distribution of price for each Airbnb listing in Barcelona across districts, room types, and geographical locations in 3 plots.
This data was compiled November 9, 2019.  
                    **Source:** http://insideairbnb.com/get-the-data.html _")

app <- Dash$new()

# Load the data here

app$layout(
  # TITLE BAR
  htmlDiv(
    list(
      heading_main
    ), style = list('columnCount'=1, 
                    'background-color'= '#271A52', 
                    'color'='white',
                    'text-align'='center')
  ),
  # SIDEBAR
  htmlDiv(
    list(
      htmlDiv(
        list(
          htmlDiv(
            list(
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              # Dropdown
              htmlLabel('Select price range :', style = list("font-size" = "15pt", "font-weight" = "500", "letter-spacing" = "1px", "color"="#9B2428")),
              htmlDiv(id='output-container-range-slider'),
              slider,
              
              # Use htmlBr() for line breaks
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              
              #checklists
              htmlLabel('Select district(s) : ', style = list("font-size" = "15pt", "font-weight" = "500", "letter-spacing" = "1px", "color"="#9B2428")),
              htmlBr(),
              checklist,
              
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              

              #logbutton
              htmlLabel('Select y scale : ' , style = list("font-size" = "15pt", "font-weight" = "500", "letter-spacing" = "1px", "color"="#9B2428")),
              htmlBr(),
              logbutton,
              
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              
              htmlLabel('Select room type(s) : ', style = list("font-size" = "15pt", "font-weight" = "500", "letter-spacing" = "1px", "color"="#9B2428")),
              checklist2,
              
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              htmlBr(),
              # Some placeholder text
              text), style = list('background-color'='#FFF8CF', 
                            'columnCount'=1, 
                            'white-space'='pre-line',
                            "flex-basis" = "20%",
                            'text-align'='center')
          ),
          htmlDiv(
            list(
              htmlDiv(
                list(
                  htmlDiv(
                    list(
                      
                      htmlBr(),
                      
                      # map here
                      graph_0,
                      
                      # histograms here
                      graph_1,
                      graph_2
                    ), style=list(  "flex-basis"='100%')
                  )
                  
                ), style = list('display'='flex',"flex-basis"='100%')
              )
              
              
            ), style = list('display'='flex',"flex-basis"='100%')
          )
        ), style=list('display'='flex',"flex-basis"='100%')
      )
    ), style = list('display'='flex',"flex-basis"='100%')
  )
)


# app$layout(
# 	htmlDiv(
# 		list(
# 			 heading_main,
# 			 graph_0,
# 			 htmlLabel('Select price range :'),
# 			 htmlDiv(id='output-container-range-slider'),
# 			 slider,
# 			 htmlLabel('Select y scale : '),
# 			 logbutton,
# 			 htmlLabel('Select district(s) : '),
# 			 checklist,
# 			 htmlLabel('Select room type(s) : '),
# 			 checklist2,
# 			 graph_1,
# 			 graph_2
# 		)
# 	)
# )

#app callbacks
app$callback(
  #update figure of gap-graph
  output=list(id = 'map', property='figure'),
  #based on values of components
  params=list(input(id = 'slider', property='value'),
              input(id = 'checklist', property='value'),
              input(id = 'checklist2', property='value')),
  #this translates your list of params into function arguments
  function(price.sliderr, checking, checking2) {
    map_maker(price.sliderr, checking, checking2)
  })

app$callback(
  #update figure of gap-graph
  output=list(id = 'violin1', property='figure'),
  #based on values of components
  params=list(input(id = 'slider', property='value'),
              input(id = 'yaxis-type', property='value'),
              input(id = 'checklist', property='value')),
  #this translates your list of params into function arguments
  function(price.sliderr, yaxis_scale, checking) {
    violin_plot1(price.sliderr, yaxis_scale, checking)
  })

app$callback(
  #update figure of gap-graph
  output=list(id = 'violin2', property='figure'),
  #based on values of components
  params=list(input(id = 'slider', property='value'),
              input(id = 'yaxis-type', property='value'),
              input(id = 'checklist2', property='value')),
  #this translates your list of params into function arguments
  function(price.sliderr, yaxis_scale, checking2) {
    violin_plot2(price.sliderr, yaxis_scale, checking2)
  })

app$callback(
  output(id = 'output-container-range-slider', property='children'),
  params=list(input(id='slider', property='value')),
  function(value) {
    paste0("You have selected ", value[1], " to ", value[2], " \u20AC") 
  })



app$run_server(debug=TRUE)