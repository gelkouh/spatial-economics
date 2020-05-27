# Potential packages and data code

library(sf) # for shape files
library(rgdal) # Bindings for the Geospatial Data Abstraction Library
library(rgeos) # Interface to Geometry engine - Open Source
library(tmap) # Gives us more mapping power
library(tmaptools)
library(RColorBrewer) # Gives us more colors for our maps
library(sp) # Lets us convert .csv to spatial points data frame
library(raster)
library(adehabitatHR) # For kernel density estimations
library(dismo)
library(spData)
library(spDataLarge)
library(ggmap)
library(magrittr)
library(raster) 
library(dismo)
library(tigris)
options(tigris_use_cache = TRUE)
library(USAboundaries)

fires_1990 <- readOGR(file.path(ddir,"1990s"))
fires_2000 <- readOGR(file.path(ddir,"2000s"))