# spatial-economics
The home of all code for the Oeconomica Spatial Economics cohort for 2019–2020.

# Data managment and setting up your R project
All data used in this project will be kept in a Google Drive folder. Please make sure you sync this Google Drive folder (`Spatial Economics Cohort (Shared Folder)`) to your computer.

Now, go the the `spatial-economics` folder that downloaded when you forked this repository (the file you are reading is in this folder). In this folder, do the following:
- Open RStudio, and create a new project (specifically, create a new directory)
  - Name the new directory `spatial-economics`
  - Create the project as a subdirectory of the `spatial-economics` folder we already have downloaded
  - Do not check "Create a git repository"
- In your new R project, create a file called: `data.R`
  - In this file, put the line of code equivalent to: `ddir <- "/Users/gelkouh/Google Drive (UChicago)/Spatial Economics Cohort (Shared Folder)/Cohort Research Paper/Data"` 
  - (note: you may need to begin the file path in your code with "C:" if you are not using a Mac)
  - Save it in the same folder as the project your just created
  
The `data.R` file will allow us to write code that is system agnostic: in other words it can call a standard file (`data.R`) that we will have on all our machines and then we will have an object called ddir in our R environment which can be used to tell our computer where to look for data. 

(thank you to ekarsten for some of this)
