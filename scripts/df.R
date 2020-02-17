#===================================
# Creating the data frame
#===================================

#-----------------------------------
# Setting up workspace
#-----------------------------------

# This snippet of code is a little loop that makes my code work on your computer
root <- getwd()
while(basename(root) != "spatial-economics") {
  root <- dirname(root)
}

# This line runs the script in your data.R file so that each person can have
# their data in a different place because everyone's file structure will be 
# a little differnt
source(file.path(root, "data.R"))

# Leoading the packages we want
library(tidyverse)
library(haven) #for reading stata data

#-----------------------------------
# Loading In the Data
#-----------------------------------

# General code: 
# df <- read_XXX(file.path(ddir, "Folder", "filename.ext"))


