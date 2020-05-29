# Spatial Economics Cohort Final Paper

# Everything your need to run this code (data and detailed instructions) is here:
# https://github.com/gelkouh/spatial-economics

# This snippet of code is a little loop that makes my code work on your computer
root <- getwd()
while(basename(root) != "spatial-economics") { # this is the name of your project directory you want to use
  root <- dirname(root)
}

# This line runs the script in your data.R file so that each person can have
# their data in a different place because everyone's file structure will be 
# a little differnt
source(file.path(root, "data.R"))

# Loading the packages we want (they will install if you do not have them already)
if (!require(tidyverse)) install.packages('tidyverse')
library(tidyverse)
if (!require(readxl)) install.packages('readxl')
library(readxl)
if (!require(tm)) install.packages('tm')
library(tm)
if (!require(plm)) install.packages('plm')
library(plm)
if (!require(AER)) install.packages('AER')
library(AER)
if (!require(stargazer)) install.packages('stargazer')
library(stargazer)
if (!require(reshape)) install.packages('reshape')
library(reshape)
if (!require(reshape2)) install.packages('reshape2')
library(reshape2)
if (!require(tidyr)) install.packages('tidyr')
library(tidyr)
if (!require(rgdal)) install.packages('rgdal')
library(rgdal)
if (!require(rgeos)) install.packages('rgeos')
library(rgeos)
if (!require(tmap)) install.packages('tmap')
library(tmap)
if (!require(leaflet)) install.packages('leaflet')
library(leaflet)
if (!require(RColorBrewer)) install.packages('RColorBrewer')
library(RColorBrewer)
if (!require(sp)) install.packages('sp')
library(sp)
if (!require(raster)) install.packages('raster')
library(raster)
if (!require(adehabitatHR)) install.packages('adehabitatHR')
library(adehabitatHR)
if (!require(tmaptools)) install.packages('tmaptools')
library(tmaptools)
if (!require(gridExtra)) install.packages('gridExtra')
library(gridExtra)

#-----------------------------------
# Loading and Cleaning the Data
#-----------------------------------

# Where we're going: 
# We are trying to get a panel data dataframe that has the percentage burned 
# by forest fires of each California county in each year from 1990-2000
# with economic data about that county from a county profile supplied by the BEA
# and the housing quantities provided by Zillow

# General code for importing data: 
# df <- read_XXX(file.path(ddir, "Folder", "filename.ext"))

# Will be used to clean up county names below
delete_county_word <- c(" County", ", CA")

# County shapefiles
counties_shapes <- readOGR(file.path(ddir,"CA_Counties"))

# Forest fire intersections calculated using QGIS
intersect_1990_df <- read_csv(file.path(ddir,"Analysis Files", "Intersect2.csv"))
intersect_2000_df <- read_csv(file.path(ddir,"Analysis Files", "Intersect.csv")) # created in QGIS using Intersect function and then calculating area of each polygon
# for an idea of how this was done, see https://atcoordinates.info/2018/11/26/measuring-polygon-overlap-in-qgis-and-postgis/
intersect_df <- rbind(intersect_1990_df,intersect_2000_df)

# Zip code areas calculated using QGIS
zcta_2019_df <- read_csv(file.path(ddir,"Analysis Files", "ZCTA2019.csv"))
zipcodes_by_state_df <- read_csv(file.path(ddir,"Analysis Files", "uszips.csv")) %>% # SimpleMaps database built from U.S. Postal Service, U.S. Census Bureau, National Weather Service, American Community Survey, and the IRS
  dplyr::rename("ZCTA_2019" = "zip")
county_pop_df <- read_xlsx(file.path(ddir,"Analysis Files", "co-est2019-annres-06.xlsx"))

# Economic Indicators
econ_indicators_df <- read_csv(file.path(ddir,"Analysis Files", "CAINC30", "CAINC30_CA_1969_2018.csv")) %>% # From BEA (economic profile)
  dplyr::rename("COUNTY" = "GeoName") %>%
  dplyr::rename("ECON_INDICATOR" = "Description") %>% 
  dplyr::rename("INDICATOR_UNITS" = "Unit") %>%
  dplyr::select(-c("2012","2013","2014","2015","2016","2017","2018")) %>%
  dplyr::select(-c("GeoFIPS"))
econ_indicators_df$COUNTY <- removeWords(econ_indicators_df$COUNTY,delete_county_word)
econ_indicators_df <- econ_indicators_df %>%
  reshape2::melt(id=c("COUNTY","ECON_INDICATOR","INDICATOR_UNITS")) %>%
  dplyr::rename("YEAR"="variable") %>% 
  unite(ECON_INDICATOR, ECON_INDICATOR, INDICATOR_UNITS, sep = ".") %>% 
  spread(ECON_INDICATOR, value)
# Note: using IRS data, it is probably possible to get an idea of income by zip code (and, by definition, "GNP" by ZCTA), and we might try this in the future to get more precise results, but the IRS tables are a mess to extract from

# Housing unit data from the Census
housing_unit_df <- read_csv(file.path(ddir,"Analysis Files", "hu-est", "hu-est00int-tot.csv")) %>% 
  dplyr::rename("COUNTY1" = "COUNTY") %>%
  dplyr::rename("COUNTY" = "CTYNAME") 
housing_unit_df <- housing_unit_df[-1835,]
housing_unit_df <- housing_unit_df[ , !(names(housing_unit_df) %in% c("SUMLEV","STATE","COUNTY1","HUCENSUS2010","HUESTBASE2000"))]
housing_unit_df$COUNTY <- removeWords(housing_unit_df$COUNTY,delete_county_word)
colnames(housing_unit_df) <- c("COUNTY",2000:2010)
housing_unit_df <- na.omit(housing_unit_df) %>%
  reshape2::melt(id=c("COUNTY")) %>%
  dplyr::rename("YEAR"="variable") %>%
  dplyr::rename("HOUSING_UNIT_QUANTITY_CENSUS"="value")

# Zillow listing data
zillow_county_for_sale_listings_df <- read_csv(file.path(ddir,"Analysis Files", "County_Zhvi_AllHomes.csv")) %>% # https://www.zillow.com/research/data/
  dplyr::rename("COUNTY" = "RegionName") %>%
  filter(State == "CA")
zillow_county_for_sale_listings_df$COUNTY <- removeWords(zillow_county_for_sale_listings_df$COUNTY,delete_county_word)
zillow_county_for_sale_listings_df <- zillow_county_for_sale_listings_df %>%
  dplyr::select(-contains(c("-02","-03","-04","-05","-06","-07","-08","-09","-10","-11","-01"))) %>%
  dplyr::select(-contains(c("2012","2013","2014","2015","2016","2017","2018","2019","2020")))
colnames(zillow_county_for_sale_listings_df) <- c(1,2,"COUNTY",1990:2011)
zillow_county_for_sale_listings_df <- zillow_county_for_sale_listings_df %>%
  dplyr::select(c("COUNTY","1996","1997","1998","1999","2000","2001","2002","2003","2004","2005","2006","2007","2008","2009","2010","2011")) %>%
  reshape2::melt(id=c("COUNTY")) %>%
  dplyr::rename("YEAR"="variable") %>%
  dplyr::rename("ZILLOW_FOR_SALE_LISTINGS_QUANTITY_DEC31"="value")
  
# A couple other potential data sources:
# http://www.dof.ca.gov/Forecasting/Demographics/Estimates/
# http://www.dof.ca.gov/Forecasting/Demographics/Estimates/E-8/2000-10/
# http://www.dof.ca.gov/Forecasting/Demographics/Estimates/E-8/
# http://www.dof.ca.gov/Forecasting/Demographics/Estimates/e-5/

# Rename variables so we can merge datasets and calculate a percentage-burned metric by ZCTA
intersect_df <- intersect_df %>%
  dplyr::rename("INTERSECT_SHAPE_AREA" = "INT_AREA") %>%
  dplyr::rename("ZCTA_2019" = "ZCTA5CE10") %>%
  dplyr::rename("YEAR" = "YEAR_") %>%
  dplyr::select(-c("GEOID10","ALAND10","AWATER10"))
zcta_2019_df <- zcta_2019_df %>%
  dplyr::rename("ZCTA_SHAPE_AREA" = "ZCTA_AREA2") %>%
  dplyr::rename("ZCTA_2019" = "ZCTA5CE10")
zcta_2019_df <- merge(zcta_2019_df,zipcodes_by_state_df,by="ZCTA_2019",all.x=TRUE) %>%
  filter(state_id == "CA") %>%
  dplyr::select(c("ZCTA_2019","ZCTA_SHAPE_AREA","POPULATION"="population","COUNTY"="county_name"))
county_pop_df$COUNTY <- removeWords(county_pop_df$COUNTY,delete_county_word)
zcta_2019_df <- merge(zcta_2019_df,county_pop_df,by="COUNTY",all.x = TRUE)

# Now we calculate the percentage of each ZCTA burned by each fire
percentage_df <- merge(zcta_2019_df,intersect_df,by="ZCTA_2019", all=TRUE) 
percentage_df$FIRE_LENGTH_DAYS <- as.Date(as.character(percentage_df$CONT_DATE), format="%Y-%m-%d")- # make a variable to see how long a fire was from alarm to containment
  as.Date(as.character(percentage_df$ALARM_DATE), format="%Y-%m-%d") 
percentage_df <- percentage_df %>%
  mutate("PERCENT_ZCTA_BURNED" = (INTERSECT_SHAPE_AREA/ZCTA_SHAPE_AREA) * 100) %>%
  mutate(PERCENT_ZCTA_BURNED = coalesce(PERCENT_ZCTA_BURNED, 0)) %>% # replaces NA with 0 where there were no fires
  dplyr::rename("FIRE_YEAR"="YEAR","ZCTA_POP" = "POPULATION")

# Weights were calculated using 2019 data because that is what is in the county to zip code file
county_weighted_percentage_df <- percentage_df %>%
  mutate("ZCTA_BY_COUNTY_WEIGHT" = (ZCTA_POP/COUNTY_POP))
weighted_county_percent <- county_weighted_percentage_df %>%
  group_by(COUNTY,FIRE_YEAR) %>%
  summarise(PERCENT_COUNTY_BURNED_WEIGHTED = sum(ZCTA_BY_COUNTY_WEIGHT*PERCENT_ZCTA_BURNED))
county_weighted_percentage_df <- merge(county_weighted_percentage_df,weighted_county_percent,by=c("COUNTY","FIRE_YEAR"), all.x = TRUE) %>%
  dplyr::rename("YEAR"="FIRE_YEAR")

# Add Zillow data and clean up data some more by removing rows that do not have county information and dropping unnecessary columns  
county_weighted_percentage_df <- merge(county_weighted_percentage_df,zillow_county_for_sale_listings_df,by=c("COUNTY","YEAR"), all.x =TRUE)
county_weighted_percentage_df <- merge(county_weighted_percentage_df,housing_unit_df,by=c("COUNTY","YEAR"), all.x=TRUE)
drops <- c("ZCTA_SHAPE_AREA","STATE","UNIT_ID","OBJECTIVE","State","Metro","CountyName","City","OBJECTID","AGENCY","INC_NUM","REPORT_AC","GIS_ACRES","SHAPEAREA","SHAPELEN","INTERSECT_SHAPE_AREA","RegionID","SizeRank","RegionType","StateName")
county_weighted_percentage_df <- county_weighted_percentage_df[ , !(names(county_weighted_percentage_df) %in% drops)]
county_weighted_percentage_df <- county_weighted_percentage_df[!is.na(county_weighted_percentage_df$COUNTY),] %>%
  dplyr::rename("ZCTA"="ZCTA_2019")

# Add economic indicators and include only one observation per year per county for panel dataframe to use in analysis
panel_df <- merge(county_weighted_percentage_df,econ_indicators_df,by = c("COUNTY","YEAR"), all.y = TRUE) %>%
  dplyr::select(-c("ZCTA","HOUSING_UNIT_QUANTITY_CENSUS","ZCTA_POP","COUNTY_POP","ALARM_DATE","CONT_DATE","FIRE_LENGTH_DAYS","FIRE_NAME","PERCENT_ZCTA_BURNED","ZCTA_BY_COUNTY_WEIGHT")) %>%
  distinct(.keep_all= TRUE) %>%
  mutate(PERCENT_COUNTY_BURNED_WEIGHTED = coalesce(PERCENT_COUNTY_BURNED_WEIGHTED, 0))
names(panel_df) <- gsub(" ", "_", names(panel_df))
names(panel_df) <- gsub(",", "", names(panel_df))
names(panel_df) <- gsub("\\(", "", names(panel_df))
names(panel_df) <- gsub("/", "", names(panel_df))
names(panel_df) <- gsub(")", "", names(panel_df))
names(panel_df) <- gsub("'", "", names(panel_df))
panel_df$COUNTY <- as.factor(panel_df$COUNTY)
panel_df$YEAR <- as.factor(panel_df$YEAR)

# This outputs our panel_df dataframe as a .csv to the folder where all the files used to construct it reside (I've already done this)
#write.csv(panel_df,file.path(ddir,"Analysis Files", "panel.csv"), row.names = FALSE)

# This removes all objects from the environment except for our panel_df we just made
#rm(list=setdiff(ls(), "panel_df"))

#-----------------------------------
# Data Exploration and Analysis
#-----------------------------------

# Here are some of the more likely variables that can be copied and pasted to save time:
# PERCENT_COUNTY_BURNED_WEIGHTED ZILLOW_FOR_SALE_LISTINGS_QUANTITY_DEC31 Farm_proprietors_income.Thousands_of_dollars 
# Farm_proprietors_employment_6.Number_of_jobs Proprietors_income.Thousands_of_dollars Proprietors_employment.Number_of_jobs
# Wage_and_salary_employment.Number_of_jobs Average_earnings_per_job_dollars.Dollars
# Average_nonfarm_proprietors_income.Dollars Average_wages_and_salaries.Dollars Employer_contributions_for_employee_pension_and_insurance_funds_5.Thousands_of_dollars
# Dividends_interest_and_rent_2.Thousands_of_dollars

# Maps of the average percent of each county burned in each fire and county populations
mean_percent_df <- weighted_county_percent %>%
  group_by(COUNTY) %>%
  summarise(MEAN_PERCENT_COUNTY_BURNED_PER_FIRE = mean(PERCENT_COUNTY_BURNED_WEIGHTED))
county_pop_df <- percentage_df %>%
  dplyr::select(COUNTY, COUNTY_POP) %>%
  distinct(.keep_all= TRUE)
counties_shapes@data <- merge(counties_shapes@data, mean_percent_df, by.x = "NAME", by.y="COUNTY", all.x=TRUE)
counties_shapes@data <- merge(counties_shapes@data, county_pop_df, by.x = "NAME", by.y="COUNTY", all.x=TRUE)
mean_percent_map <- tm_shape(counties_shapes) + tm_fill("MEAN_PERCENT_COUNTY_BURNED_PER_FIRE", 
                                                        title = "Average Weighted Percent of County Burned per Fire")
pop_map <- tm_shape(counties_shapes) + tm_fill("COUNTY_POP", 
                                                        style="quantile",
                                                        title = "Population per County")

# Plots exploring various relationships in the data
p_zillow <- ggplot(filter(panel_df,PERCENT_COUNTY_BURNED_WEIGHTED!=0), aes(x = PERCENT_COUNTY_BURNED_WEIGHTED, y = ZILLOW_FOR_SALE_LISTINGS_QUANTITY_DEC31)) + 
  geom_point() +
  xlab("Weighted Percent County Burned") +
  ylab("Year-End Zillow For-Sale Listings Quantity") +
  ggtitle("All Counties by Year")
p_average_inc <- ggplot(filter(panel_df,PERCENT_COUNTY_BURNED_WEIGHTED!=0), aes(x = PERCENT_COUNTY_BURNED_WEIGHTED, y = Average_earnings_per_job_dollars.Dollars)) + 
  geom_point() +
  xlab("Weighted Percent County Burned") +
  ylab("Average Earnings per Job ($)") +
  ggtitle("All Counties by Year")
p_insurance <- ggplot(filter(panel_df,PERCENT_COUNTY_BURNED_WEIGHTED!=0), aes(x = PERCENT_COUNTY_BURNED_WEIGHTED, y = Employer_contributions_for_employee_pension_and_insurance_funds_5.Thousands_of_dollars)) + 
  geom_point()
p_number_jobs <- ggplot(filter(panel_df,PERCENT_COUNTY_BURNED_WEIGHTED!=0), aes(x = PERCENT_COUNTY_BURNED_WEIGHTED, y = Wage_and_salary_employment.Number_of_jobs)) + 
  geom_point()
p_sierra_time <- ggplot(filter(panel_df,COUNTY=="Sierra"), aes(x = YEAR, y = Wage_and_salary_employment.Number_of_jobs)) + 
  geom_point() +
  xlab("Year") +
  ylab("Number of Wage and Salary Jobs") +
  ggtitle("Sierra County (19 percent (weighted) of county burned in 1994)")
p_san_bernardino_time <- ggplot(filter(panel_df,COUNTY=="San Bernardino"), aes(x = YEAR, y = Wage_and_salary_employment.Number_of_jobs)) + 
  geom_point() +
  xlab("Year") +
  ylab("Number of Wage and Salary Jobs") +
  ggtitle("San Bernardino County (8 percent (weighted) of county burned in 2003)")
p_salary_number_jobs_la <- ggplot(filter(panel_df,COUNTY=="Los Angeles"), aes(x = Wage_and_salary_employment.Number_of_jobs, y = Average_wages_and_salaries.Dollars)) + 
  geom_point()
p_salary_zillow_la <- ggplot(filter(panel_df,COUNTY=="Los Angeles"), aes(x = Average_wages_and_salaries.Dollars, y = ZILLOW_FOR_SALE_LISTINGS_QUANTITY_DEC31)) + 
  geom_point() +
  xlab("Average Wages and Salaries ($)") +
  ylab("Year-End Quantity of Zillow Housing Listings")
p_YEAR_zillow_la <- ggplot(filter(panel_df,COUNTY=="Los Angeles"), aes(x = YEAR, y = ZILLOW_FOR_SALE_LISTINGS_QUANTITY_DEC31)) + 
  geom_point() +
  xlab("Year") +
  ylab("Year-End Quantity of Zillow Housing Listings")

# Regression testing relationship between a fire's length and the weighted percent of a county burned by it
fire_length_df <- county_weighted_percentage_df %>%
  filter(!is.na(FIRE_LENGTH_DAYS))
fire_length_lm <- lm(PERCENT_COUNTY_BURNED_WEIGHTED ~ FIRE_LENGTH_DAYS, fire_length_df)

# Fixed effects regressions testing relationships within the data
lm_number_jobs_burn <- plm(Wage_and_salary_employment.Number_of_jobs ~ PERCENT_COUNTY_BURNED_WEIGHTED, 
                data = panel_df, index = c("COUNTY", "YEAR"), model = "within",effect = "twoways")
lm_average_inc <- plm(Average_earnings_per_job_dollars.Dollars ~ PERCENT_COUNTY_BURNED_WEIGHTED, 
                      data = panel_df, index = c("COUNTY", "YEAR"), model = "within",effect = "twoways")
lm_zillow <- plm(ZILLOW_FOR_SALE_LISTINGS_QUANTITY_DEC31 ~ PERCENT_COUNTY_BURNED_WEIGHTED, 
                 data = panel_df, index = c("COUNTY", "YEAR"), model = "within",effect = "twoways")

lm_salary_zillow <- plm(ZILLOW_FOR_SALE_LISTINGS_QUANTITY_DEC31 ~ Average_wages_and_salaries.Dollars, 
                data = panel_df, index = c("COUNTY", "YEAR"), model = "within",effect = "twoways")
lm_salary_number_jobs <- plm(Wage_and_salary_employment.Number_of_jobs ~ Average_wages_and_salaries.Dollars, 
                             data = panel_df, index = c("COUNTY", "YEAR"), model = "within",effect = "twoways")

# LaTeX regression tables for output
stargazer(lm_number_jobs_burn, lm_average_inc, lm_zillow,
          digits = 3,
          header = FALSE,
          type = "latex", 
          title = "Linear Panel Regression Models of Economic Indicators Against Weighted Percent of County Burned",
          model.numbers = FALSE,
          column.labels = c("Number of Wage and Salary Jobs", "Average Earnings per Job ($)", "Year-End Zillow For-Sale Listings Quantity"))

stargazer(fire_length_lm,
          digits = 3,
          header = FALSE,
          type = "latex", 
          model.numbers = FALSE)

stargazer(lm_salary_number_jobs,lm_salary_zillow,
          digits = 3,
          header = FALSE,
          type = "latex", 
          title = "Linear Panel Regression Models between Economic Indicators and Zillow Housing Data",
          model.numbers = FALSE,
          column.labels = c("Number of Wage and Salary Jobs", "Year-End Zillow For-Sale Listings Quantity"))

# Plots and figures to export
#mean_percent_map
#pop_map
#gridExtra::grid.arrange(p_salary_zillow_la, p_YEAR_zillow_la, ncol=2)
#gridExtra::grid.arrange(p_san_bernardino_time, p_sierra_time, ncol=1)
#p_zillow
#p_average_inc


# Push everything to GitHub when done:
# Make sure working directory is set to spatial-economics (pwd)
# git status
# git pull
# git add [file.extension or folder]
# git commit -m "scripts"
# git push

