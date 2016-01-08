################################################################################
# Mapping Locations of Indeed Job Postings
################################################################################

# The search results from Indeed come with exact longtitudes and latitudes, so 
# we can try plotting the results of the searches to look for patterns

# For this file, I wanted to experiment with the data.table package

# install.packages("data.table")

library("ggmap") # To plot  maps
library("dplyr")
library("data.table") # Alternative to data.frames

################################################################################
# Importing Data 
################################################################################

# `goofing_off_indeed.R` has a more in-depth explanation of the process here. 
# We're just collecting job search data from Indeed's API and cleaning it.

xml_top <- xmlRoot(xmlParse("http://api.indeed.com/ads/apisearch?publisher=9724091492889092&q=java&l=20001&sort=&radius=10&st=&jt=&start=1&limit=50&fromage=30&filter=&latlong=1&co=us&chnl=&userip=1.2.3.4&useragent=Mozilla/%2F4.0%28Firefox%29&v=2"))

xml_data <- xml_top[[10]] # Extracting the job posting information

# Code below is dumb -- redundant to call data.table after lapply + data.frame

plotting_data <- data.table(ldply(xmlToList(xml_data), function(x) 
                              data.frame(x, stringsAsFactors = F))) 

# Notice the stringsAsFactors there to get the variable types input correctly

################################################################################
# Cleaning Data 
################################################################################

# Start by subsetting data
plotting_data %<>% select(jobtitle,city,state,latitude,longitude,company)

plotting_data$latitude %<>%  as.numeric() # Converting lat and lon to numeric
plotting_data$longitude %<>%  as.numeric()

tbl_df(plotting_data) # Displaying subsetted data

################################################################################
# Plotting Map 
################################################################################

mean_lat <- mean(plotting_data$latitude) # Getting means to find center of posts
mean_lon <- mean(plotting_data$longitude)

centerLoc <- c(lon=mean_lon,lat=mean_lat) # Coordinates of center of job posts

crimeMap <- get_map(location=centerLoc, source="google", # From ggmap, pulls a 
                    maptype="terrain", crop=FALSE,       # google maps
                    zoom=11)

jobs_map <- ggmap(crimeMap) + # Plotting map with data points
              geom_point(data=plotting_data, aes(x=longitude, y=latitude), 
                         alpha=.65, color="black") + # alpha gives transparency
              labs(x = 'Longitude', y = 'Latitude') +
              ggtitle("Map of Job Postings Listed on Indeed")

jobs_map # Prints final map
