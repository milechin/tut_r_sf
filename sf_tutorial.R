# ------------------------------------------------------#
#                                                       #
#  GIS Using R: sf package                              #
#  Dennis Milechin                                      #
#  2/5/2026                                            #
#                                                       #
# ------------------------------------------------------#


#----------------------------------------#
#  Install packages                   ####
#----------------------------------------#


install.packages("sf")
install.packages("spData")
install.packages("tidyverse")


#----------------------------------------#
#  Loading and Plotting Data          ####
#----------------------------------------#
library(sf) 
library(spData)
library(tidyverse)
library(units)

# Create a folder for our project
# Set working directory pointing to that project.


#----------------------------------------#
# Load MassGIS MBTA Rapid Transit Data####
#----------------------------------------#

# Go to  MassGIS
# https://www.mass.gov/info-details/massgis-data-layer

# Download MBTA Subway data
# https://www.mass.gov/info-details/massgis-data-mbta-rapid-transit


# Unzip the file 
# Read in the shapefile
mbta_file <- "MBTA_ARC.shp"
mbta_transit <- read_sf(mbta_file)


# Explore the data
head(mbta_transit)
summary(mbta_transit)
colnames(mbta_transit)

# We can use ggplot to plot the data
ggplot( data=mbta_transit) + 
  geom_sf()


# As with normal ggplot workflow, we can add
# titles, subtitles, and axis labels.
ggplot() + 
  geom_sf(data=mbta_transit) +
  xlab("Longitude") +
  ylab("Latitude") +
  ggtitle("MBTA") +
  theme_bw()


# We can specify appearance of the features
ggplot() + 
  geom_sf(data=mbta_transit,  color="orange" ) +
  theme_bw()


# TIP: You can read in shapefile without unziping the file
mbta_file <- "/vsizip/data/mbta_rapid_transit.zip/MBTA_ARC.shp"
mbta_transit_zip <- read_sf(mbta_file)

# Inspect the table
mbta_transit_zip

ggplot() +
  ggtitle("Reading from Zip File") +
  geom_sf(data=mbta_transit_zip,  color="red" ) +
  theme_bw()

# We could also read the file directly from the web
mbta_file <- "/vsizip/vsicurl/https://s3.us-east-1.amazonaws.com/download.massgis.digital.mass.gov/shapefiles/state/mbta_rapid_transit.zip/MBTA_ARC.shp"
mbta_transit_curl <- read_sf(mbta_file)

# Inspect the table
mbta_transit_curl

ggplot( ) + 
  ggtitle("Reading from web") +
  geom_sf(data=mbta_transit_curl , color="blue" ) +
  theme_bw()



#----------------------------------------#
# Working with Geodatabase File       ####
#----------------------------------------#

# Load a geodatabase file from "tutorial_files.zip" package I created

gdb_file <- "/vsizip/vsicurl/https://rcs.bu.edu/examples/gis/tutorials/r_sf_package/tutorial_files.zip/tlgdb_2019_a_25_ma.gdb"
ma_state <- read_sf(gdb_file)

# Notice the warning message.  Remember that some GIS files can
# contain multiple layers, like a Geodatabase file.  So we need to be
# specific what layer we want.

# Let's list the layers available in the file
st_layers(gdb_file)

# Let's load the "state_boundary" layer
ma_state <- read_sf( gdb_file, layer="state_boundary" )

head(ma_state)

ggplot() + 
  geom_sf(data=ma_state) +
  theme_bw()

# Now we would like to plot both the state boundary and mbta layer on 
# one plot.

ggplot() + 
  geom_sf(data=ma_state) +
  geom_sf( data=mbta_transit, color="orange" ) +
  theme_bw()

# What happens if we plot mbta_transit first?

ggplot( data=mbta_transit) + 
  geom_sf( color="orange" ) +
  geom_sf( data=ma_state ) +
  theme_bw()

# In this case the State Layer is drawn on top of the subway layer.
# So keep in mind the order of layers matter.

# What if we want to focus only on the Boston area only?

# We can use the property of mbta_transit layer to 

bbox <- st_bbox(mbta_transit)

bbox

x_extent <- c(bbox$xmin, bbox$xmax)
y_extent <- c(bbox$ymin, bbox$ymax)


ggplot( data=ma_state ) + 
  geom_sf() +
  geom_sf( data=mbta_transit, color="orange" ) +
  coord_sf(xlim = x_extent, ylim = y_extent) +
  theme_bw()


#### TIP: There are R packages that can help get data
# from webservers and load it as "sf" objects
# Example 'tidycensus'
# https://walker-data.com/tidycensus/articles/spatial-data.html



#----------------------------------------#
#  Color by Attribute                 ####
#----------------------------------------#

#### START - SKIP IF ALREADY INITIALIZED 
library(sf) 
library(spData)
library(tidyverse)
library(units)

# load the GIS files
gdb_file <- "/vsizip/vsicurl/https://rcs.bu.edu/examples/gis/tutorials/r_sf_package/tutorial_files.zip/tlgdb_2019_a_25_ma.gdb"
ma_state <- read_sf( gdb_file, layer="state_boundary" )

mbta_file <- "/vsizip/vsicurl/https://s3.us-east-1.amazonaws.com/download.massgis.digital.mass.gov/shapefiles/state/mbta_rapid_transit.zip/MBTA_ARC.shp"
mbta_transit <- read_sf(mbta_file)

# Get our area of interest extent parameters
bbox <- st_bbox(mbta_transit)
x_extent <- c(bbox$xmin, bbox$xmax)
y_extent <- c(bbox$ymin, bbox$ymax)

#### STOP - SKIP IF ALREADY INITIALIZED 

# Let's see what column we can use to color the subway lines
head(mbta_transit)
names(mbta_transit)
unique(mbta_transit$LINE)

ggplot() + 
  geom_sf( data=ma_state) +
  geom_sf( data=mbta_transit, aes( color=LINE )) +
  coord_sf(xlim = x_extent, ylim = y_extent) +
  theme_bw()

# We can specify the colors associated with each subway line by
# using scale_color_manual() function.


ggplot( ) + 
  geom_sf( data=ma_state ) +
  geom_sf( data=mbta_transit, aes( color=LINE ), linewidth=1 ) +
  scale_color_manual(values=c("blue", "green", "orange", "red", "grey" ))  +
  coord_sf(xlim = x_extent, ylim = y_extent) +
  theme_bw()


# Let's add the location of the stations stops using the CSV file.
df_stations <- read.csv("https://rcs.bu.edu/examples/gis/tutorials/r_sf_package/mbta_stations.csv")

# Examine the data
head(df_stations)

ggplot(data=df_stations) +
  geom_sf()

# We get an error message.
class(df_stations)

# We need to convert it to an "sf" object.
mbta_stations <- st_as_sf(df, coords=c("POINT_X", "POINT_Y"))


ggplot() +
  geom_sf(data=mbta_stations)

# Now let's see if we can included in our map.


ggplot(  ) + 
  geom_sf( data=ma_state ) +
  geom_sf( data=mbta_transit, aes( color=LINE ), linewidth=1 ) +
  scale_color_manual(values=c("blue", "green", "orange", "red", "grey" ))  +
  geom_sf( data=mbta_stations) +
  coord_sf(xlim = x_extent, ylim = y_extent) +
  theme_bw()

# Notice the Error message.  Since mbta_stations is the last
# layer we added to the plot, it is probably the trouble maker.

# Let's check what coordinate system is set for mbta_stations.
st_crs(mbta_stations)

# NA, so we need to assign a coordinate system. Where do we get that information?

mbta_stations <- st_as_sf(df, coords=c("POINT_X", "POINT_Y"), crs=4326)

# Try again

ggplot( data=ma_state ) + 
  geom_sf() +
  geom_sf( data=mbta_transit, aes( color=LINE ), linewidth=1 ) +
  scale_color_manual(values=c("blue", "green", "orange", "red", "grey" ))  +
  geom_sf( data=mbta_stations) +
  coord_sf(xlim = x_extent, ylim = y_extent) +
  theme_bw()


# Let's check to see of the CRS is the same for all layers so far:

st_crs(ma_state)
st_crs(mbta_transit)
st_crs(mbta_stations)

# Another way to check
st_crs(ma_state) == st_crs(mbta_transit)
st_crs(ma_state) == st_crs(mbta_stations)

# What does this tell us about the ggplot function?
# Where could different CRS become a problem?


# It good practice to choose a project CRS and transform 
# all layers to it.

project_crs <- st_crs(ma_state)
mbta_stations <- st_transform(mbta_stations, crs=project_crs)

project_crs == st_crs(mbta_transit)
project_crs == st_crs(mbta_stations)
project_crs == st_crs(ma_state)


#  Plotting resources:

# https://r-spatial.org/r/2018/10/25/ggplot2-sf.html
# https://r-spatial.org/r/2018/10/25/ggplot2-sf-2.html
# https://r-spatial.org/r/2018/10/25/ggplot2-sf-3.html




#---------------------------------------------------------------#
#  Assemble GIS functions to accomplish a task               ####
#---------------------------------------------------------------#

#### START - SKIP IF LOADED
library(sf) 
library(spData)
library(tidyverse)
library(units)


mbta_file <- "/vsizip/vsicurl/https://s3.us-east-1.amazonaws.com/download.massgis.digital.mass.gov/shapefiles/state/mbta_rapid_transit.zip/MBTA_ARC.shp"
mbta_transit <- read_sf(mbta_file)



#### STOP - SKIP IF LOADED


## TASK: Which census tracts have a subway lines intersecting them?

# First we need to load the Census Tract
gdb_file <- "/vsizip/vsicurl/https://rcs.bu.edu/examples/gis/tutorials/r_sf_package/tutorial_files.zip/tlgdb_2019_a_25_ma.gdb"

# Which layer should we load?
st_layers(gdb_file)

ma_tract <- read_sf(gdb_file, layer="Census_Tract")


ggplot( data = ma_tract) +
  geom_sf() +
  theme_bw()

# We are only interested in the Boston area, so can we only load the data we need?

# We can create a convex hull of area of interest and then buffer that 5000 ft.

# Start with st_union()

mbta_transit |> 
  st_union() # |>
  # ggplot() +
  # geom_sf() 


# Add convex hull
mbta_transit |> 
  st_union() |>
  st_convex_hull() |>
  ggplot() +
    geom_sf( color="red") +
    geom_sf( data=mbta_transit)


# Now lets add a buffer
mbta_transit |> 
  st_union()  |>
  st_convex_hull() |>
  st_buffer(dist=5000)|>
  ggplot() +
    geom_sf( color="red") +
    geom_sf( data=mbta_transit)

# Let's save our convex hull as an area of interest

aoi <- mbta_transit |> 
  st_union()  |>
  st_convex_hull() |>
  st_buffer(dist=5000)


# Rather than reading the entire dataset, let's just census tracts that are contained 
# within the area of interest

# First we need to convert the aoi into a Well Know Text format.
aoi <- st_transform(aoi, crs=st_crs(ma_tract))
wkt_aoi <- st_as_text(aoi)

# Then we can use it to read in a subset of the data
ma_tract <- read_sf(
  gdb_file, 
  layer="Census_Tract", 
  wkt_filter=wkt_aoi
)


ggplot( ) + 
  geom_sf( data=ma_tract ) +
  geom_sf( data=aoi, fill=NA, color="red", linewidth=2) +
  geom_sf( data=mbta_transit, aes( color=LINE )) +
  scale_color_manual(values=c("blue", "green", "orange", "red", "grey" )) +
  theme_bw()

# Now let's use a function called st_intersection, to determine which census blocks
# have a subway line passing through them.

st_intersects(ma_tract, mbta_transit)
# Got an error message, let's check crs agaist project crs

project_crs <- st_crs(ma_state)

# Got an error message, let's check crs agaist project crs
project_crs == st_crs(ma_tract)

ma_tract <- st_transform(ma_tract, crs=project_crs)

# Let's try again
ma_tract$transit_intersect <- st_intersects(ma_tract, mbta_transit) |> length()

# The result is a sparse matrix.
# To make it more useful we can apply the lengths() functions to
# get the counts

lengths(intersect_result)


# We can take it a step further, we can use ifelse
# to classify a TRUE/FALSE value

ma_tract <- ma_tract |> 
  mutate(intersects = ifelse( lengths(intersect_result) == 0, FALSE, TRUE) )


colnames(ma_tract)

ggplot(data=ma_tract) +
  geom_sf( aes( fill=subway_line))


# We can add all the other layers back
bbox <- st_bbox(mbta_transit)

x_extent <- c(bbox$xmin, bbox$xmax)
y_extent <- c(bbox$ymin, bbox$ymax)

ggplot() + 
  geom_sf(data=ma_tract, aes( fill=intersects) ) +
  geom_sf( data=mbta_transit, aes( color=LINE),  linewidth=2) +
  scale_color_manual(values=c("blue", "green", "orange", "red", "grey" )) +
  #coord_sf(xlim = x_extent, ylim = y_extent) +
  theme_bw()

#----------------------------------------#
#  Working with the attribute table   ####
#----------------------------------------#

#### START - SKIP IF ALREADY INITIALIZED 
library(sf) 
library(spData)
library(tidyverse)
library(units)

#### STOP - SKIP IF ALREADY INITIALIZED 

# Let's use the "world" dataset available from spData
# and explore it.

head(world)
summary(world)
colnames(world)


# Let's plot the data
ggplot( data=world) + 
  geom_sf() + 
  coord_sf(expand = TRUE) +
  theme_bw()


# Let's examine the sample data set 'world' as an "sf" object
# and tibble form of the same data.

class( world )

# Since the world_sf contains the tibble class.
# Therefore we can use some Tidyverse functions.


# Below is a link to a page listing tidyverse functions
# that will work on sf objects:
#     https://r-spatial.github.io/sf/reference/tidyverse.html



# Let's try out
# some subsetting using our tibble knowledge

# Subset a specific column. 

colnames(world)

# By continent
world |> select(continent) 

# By population
world |> select(pop)

# By life expectancy
world |> select(lifeExp) 


# What if we are interested in only North America?

world |> 
  select(continent) |>
  distinct()

world |> 
  filter(continent == "North America")

# Let's plot it:
world |> 
  filter(continent == "North America") |>
  ggplot() + geom_sf()

# Maybe we want specifically lifeExp and pop columns:
world |> 
  filter(continent == "North America") |>
  select(name_long, lifeExp, pop) 

# Let's plot this:
world |> 
  filter(continent == "North America") |>
  select(name_long, lifeExp, pop) |>
  ggplot() + geom_sf(aes(fill=pop))


# Maybe we want to see countries with life expectancy greater than 82:
world |> 
  filter(lifeExp > 82) |>
  select(name_long, lifeExp) |>
  ggplot() + geom_sf(aes(fill=lifeExp))


# Let's get the total population by continent using 
# group-by and summarize functions
world_pop_agg <- world |>
  group_by(continent) |>
  summarize(pop = sum(pop, na.rm = TRUE))

world_pop_agg |> head()

ggplot( ) +
  geom_sf( data = world_pop_agg ) +
  ggtitle("Aggregated") +
  coord_sf(expand = FALSE) +
  theme_bw()

ggplot( ) +
  geom_sf( data = world) +
  ggtitle("Original") +
  coord_sf(expand = FALSE) +
  theme_bw()



# What if we use a tidyverse function not supported
# by sf? Like `pull()`

result_pull <- world |> pull(pop)

result_pull

class(result_pull)



#----------------------------------------#
#  Attribute Table Join               ####
#----------------------------------------#


### START - SKIP if already loaded
library(sf) 
library(spData)
library(tidyverse)
library(units)

### STOP - SKIP

# We have a coffee production table that we would
# like to use join to our attribute table

# From spData includes "coffee_data" object

head(coffee_data)
class(coffee_data)

# Is this an "sf" object?

str(coffee_data)

# How can we join this table with the "world" object?

# Let's take a look at the column names

head(world)
head(coffee_data)

world |> arrange(name_long) |> head(20)
coffee_data |> arrange(name_long) |> head(5)

# Both contain columns with country names (long_name)
# Examine the column values
world |> arrange(name_long) |> head(20)
coffee_data |> arrange(name_long) |> head(5)

# Let's look at Brazil attribute data
# and use that to confirm our joins.

world |> 
  filter(name_long == "Brazil") |>
  select( name_long, continent, area_km2, pop) |>
  st_drop_geometry()

coffee_data |> 
  filter(name_long == "Brazil")
  
  
  # We need a function that will allow us to 
  # join two tables based on a "key" column
  # in both tables.
  
  # dplyr provides several join functions that we can usel
  #  - left_join()
  #  - inner_join()
  #  - right_join()
  
  # Let's apply a left join
  data_left_join <- left_join(world, coffee_data, by=c("name_long" = "name_long"))

# We see that the coffee columns are appended to our 
# spatial attribute table.
names(data_left_join)

# We can compare the values of "Brazil"
data_left_join |> 
  filter(name_long == "Brazil") |>
  select(name_long, continent, area_km2, pop,  coffee_production_2016, coffee_production_2017)


# We can now symbolize coffee production rates.

ggplot(  ) + 
  geom_sf(data=data_left_join, aes(fill=coffee_production_2016)) +
  theme_bw()


# What if in the left_join function we switch the objects?
data_left_join_2 <- left_join(coffee_data, world, by=c("name_long" = "name_long"))


ggplot( data=data_left_join_2 ) + 
  geom_sf(aes(fill=coffee_production_2017)) +
  theme_bw()

# We will get an error.  Why?

head(data_left_join_2)
class(data_left_join_2)

# Can we convert it to a "sf" object?
names(data_left_join_2)

# Yes! Since we still retained the "geom" column

st_as_sf(data_left_join_2) |>
  ggplot() + 
  geom_sf(aes(fill=coffee_production_2017)) +
  theme_bw()

# Why only a subset of countries are shown?

# Let's try inner_join()
data_inner_join <- inner_join(world, coffee_data, by=c("name_long" = "name_long"))

ggplot( data=data_inner_join ) + 
  geom_sf(aes(fill=coffee_production_2017)) +
  theme_bw()


# Let's try right_join()
data_right_join <- right_join(world, coffee_data, by=c("name_long" = "name_long"))

ggplot( data=data_right_join ) + 
  geom_sf(aes(fill=coffee_production_2017)) +
  theme_bw()



###### Helpful resources:
#  "Geocomputation with R".
#  https://geocompr.robinlovelace.net/index.html
#
#  "Drawing beautiful maps programmatically with R, sf and ggplot2" Ã¢â‚¬â€ Part 1: Basics
#  https://r-spatial.org/r/2018/10/25/ggplot2-sf.html
#  
#  R-Spatial - Helpful articles are published here.
#  https://r-spatial.org/

####################
## QUESTIONS?
####################
##
##  Evaluation form: http://rcs.bu.edu/eval
##
##


