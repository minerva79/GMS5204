# Repository for GMS5204 (2025)

Hands-on code that we will use for classroom exercise.

## Table of contents

1. Hands-on for time series component exploration (R Language)
2. Basics with handling geospatial objects (R Language)
3. Data Wrangling (Python)
4. ML Overview (Python)

## Day 1 Session 02 & 03 - Time Series Analysis

Files in GitHub:

1. `Day01_Session03_temporal.ipynb` contains the script for hands-on activity for time series analysis; reading on
   - `Synthetic_Sampled_Temporal_Data.csv`: synthetic total count of out of hospital cardiac arrest cases 
   - `changi.csv`: matching meterological information from Changi weather station

2. `ED_Attendance` subfolder containing:
   - `app.R` script for the deployed [dashboard](https://adamquek.shinyapps.io/ED_Attendance/)
   - `attendance_at_emd.csv` extracted from [MOH](https://www.moh.gov.sg/others/resources-and-statistics/healthcare-institution-statistics-attendances-at-emergency-medicine-departments)

3. `glm_example.pdf` and `glm_example.Rmd` contain the script for logistic regression and interpretation on R. Running the Rmd on RStudio is highly recommended.

 
## Day 1 Session 04 & 05 - Geospatial Analysis

Files in GitHub:

1. `Day01_Session05_geospatial.R` and `Day01_Session05_geospatial.pdf` contains the script to be run on R-Studio. 
   - `geospatial.RData`: contains the data for base-maps, hospital locations, fire station locations and patient location (simulated).

2. `Spatial_Wrangling` subfolder containing:
   - `app.R` script for the deployed [dashboard](https://adamquek.shinyapps.io/disc_calc/)
