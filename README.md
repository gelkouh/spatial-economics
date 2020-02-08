# spatial-economics
The home of all code for the Oeconomica Spatial Economics cohort for 2019–2020.

# Data managment
All data used in this project will be kept in a Google Drive folder. Please sync this Google Drive folder to your computer.

Create a file called 

  data.R
  
In this file, put the line of code equivalent to

  ddir <- "/Users/gelkouh/Google Drive (UChicago)/Spatial Economics Cohort (Shared Folder)/Cohort Research Paper/Data"
  
  (note: you may need to begin your code with "C:" if you are not using a Mac)
  
This will allow us to write code that is system agnostic: in other words it can call a standard file (data.R) that we will have on all our machines and then we will have an object called ddir in our R environment which can be used to tell our computer where to look for data.
