library(zipcode);
library(ggplot2);
library(lubridate);
library(maps);
library(animation)
source("http://dl.dropbox.com/u/1161356/theme_map.R");


Step 2. Load data

We use the same data source on Walmart store openings as used by Nathan Yau of the FlowingData blog. This data was originally collected by Prof. Thomas Holmes, and you can find the documentation for this data-set on his webpage. We convert opening dates to the correct format and also add a variable indicating the year of opening.

 walmart = read.csv("http://goo.gl/4EWpS", stringsAsFactors = F);
walmart$OPENDATE = as.Date(walmart$OPENDATE,  "%m/%d/%Y");
walmart$openyear = year(walmart$OPENDATE);


Step 3. Merge with zipcodes

We merge our store openings data with zipcode data to get long/lat information for every location. We sort the merged data by opening date and add an id variable to represent the sequence of store openings.

 data(zipcode);
walmart      = merge(walmart, zipcode, by.x = "ZIPCODE", by.y = "zip");
walmart      = arrange(walmart, OPENDATE);
walmart$id = as.numeric(rownames(walmart));


Step 4. Construct map

We use the map_data function in ggplot2 to extract the US map with state boundaries. We construct a data frame with state centers and abbreviated state names to be used to annotate the map. We remove Alaska and Hawaii in order to maximize the visibility of plot details.

 usmap     = map_data("state");
state.info = data.frame(state.center, state.abb);
state.info = subset(state.info, !state.abb %in% c("AK", "HI"));


Step 5. Plot store openings

The next step is to create a function that plots a given number of stores on the US map. This is the basic function that we would be using while creating our animations. We use ggplot2 to create the plot by adding a layer of yellow points denoting stores on a US map with state boundaries. We also use a bigger red point to represent the most recent store opening for that subset.

 plotStore <- function(.id){

  df = subset(walmart, id <= .id);
  yr = year(df$OPENDATE[.id])
  p1 = ggplot(df, aes(x = longitude, y = latitude)) +
       geom_polygon(data = usmap, aes(x = long, y = lat, group = group),
          fill = 'gray10', colour = 'gray40', linetype = 2) +
       geom_text(data = state.info, aes(x = x, y = y, label = state.abb),
           colour = 'white') +
       geom_point(colour = 'yellow', size = 1) +
       geom_point(subset = .(id == .id), colour = alpha('red', 0.7),
           size = 9)+
       annotate('text', x = -70, y = 31, label = 'YEAR') +
       annotate('text', x = -70, y = 29, label =  yr, colour = 'red') +
       annotate('text', x = -70, y = 27, label = 'STORES') +
       annotate('text', x = -70, y = 25, label =  .id, colour = 'blue') +
       theme_map() +
       opts(title = 'GROWTH OF WALMART, 1962 TO 2010', plot.title =
            theme_text(colour = 'blue', face = 'bold', size = 20));
}


Step 6. Plot number of store openings

We now create a function to plot the number of stores opened by date. We show the trend in number of stores opened using a blue line and a red point at the end.

 plotNumStores <- function(.id){

  df = subset(walmart, id <= .id)
  p0 = ggplot(walmart, aes(x = OPENDATE, y = id)) +
       geom_point(colour = 'white') +
       geom_line(subset = .(id <= .id), colour = 'blue') +
       geom_point(subset = .(id == .id), colour = alpha('red', 0.7),
           size = 2) +
       scale_x_date(major = '10 years') +
       scale_y_continuous(breaks = c(1000, 2000, 3000)) +
       xlab(NULL) + ylab(NULL) +
       theme_base();
}


Step 7. Combine plots

The next step is to create a function that combines the two plots in Step 5 and Step 6. To do this, we use a trick illustrated in the learnr blog of creating a viewport and using it to display one of the plots as an inset.

 # create a viewport on the bottom left corner
vp = viewport(width = 0.4,
  height = 0.3, x = 0,
  y      = unit(0.7, 'lines'),
  just   = c('left','bottom')
);

# combine both plots into a single plot
animateStores <- function(.id){
  print(plotStore(.id));
  print(plotNumStores(.id), vp = vp);
}


Step 8. Create animation

We are almost done. The final step is to create the animation using the animation package. We just need to throw the animateStore function created in Step 7 into a loop, and the animation package takes care of the rest! As the process of generating a gif file is very time consuming, I have only shown the output for 100 store openings in this post.

 # Warning! Creating a gif file with 3000 frames will take lot of time!!
saveMovie(for (i in 1:nrow(walmart)) animateStores(i), clean = T);
Although, the final output is not as impressive as the visualization on FlowingData, it is not bad considering that it took less than two hours of time and 100 lines of R code. Note that it is easy to customize this code and create such a visualization for any dataset with store opening dates and zip-codes!