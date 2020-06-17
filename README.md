# spatial-economics
The home of all code for the Oeconomica Spatial Economics cohort for 2019–2020. Note: the final paper is in the `docs` folder.

# Data managment and setting up your R project
All data used in this project will be kept in a shared Google Drive folder. Please make sure you sync this Google Drive folder (`Spatial Economics Cohort (Shared Folder)`) to your computer.

If you cannot sync the Google Drive folder, or if you want to explore this project and were not part of the cohort, the data is available for download here: https://drive.google.com/file/d/1KuGNe5OkWm5ITNyqeiE4iHAYUZVY0G57/view?usp=sharing. Adjust the following steps regarding setting up the `data.R` file to reflect the file path to that of the downloaded, unzipped data folder (warning: it is somewhat large).

First, make sure you click the "Fork" button in the upper right corner of the GitHub page for this repository.

We are now going to do a couple things to set up GitHub with R:
- Open RStudio, and create a new project
  - Select "Version Control" and "Git"
  - Click the green "Clone or download" for the repository on GitHub, and copy and paste the URL of the repository into the space in RStudio 
  - Name the new directory `spatial-economics`
  - Choose to make it a subdirectory of a location you will easily find on your computer (perhaps your desktop or in your Google Drive folder; you can pick anywhere other than our cohort's shared Google Drive folder!)
- In your new R project, locate the file called: `data.R`
  - In this file, change the following line of code to reflect the path to the Data folder on your computer (if you downloaded the Data via the ZIP file link above, then this folder is just the unzipped Data folder from the download): `ddir <- "/Users/gelkouh/Google Drive (UChicago)/Spatial Economics Cohort (Shared Folder)/Cohort Research Paper/Data"` 
  - (note: you may need to begin the file path in your code with `C:` if you are not using a Mac)
  - Save it in the `spatial-economics` folder that your R project is in

The `data.R` file will allow us to write code that is system agnostic: in other words it can call a standard file (`data.R`) that we will have on all our machines and then we will have an object called ddir in our R environment which can be used to tell our computer where to look for data. 

(thank you to https://github.com/ekarsten for some of this)
