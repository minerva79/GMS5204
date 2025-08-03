# Repository for GMS5204 (2025) - Day 1

Hands-on code that we will use for classroom exercise.

## Table of contents

1. Hands-on for time series component exploration (R Language)
2. Basics with handling geospatial objects (R Language)
3. ML Overview (Python)

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


## Day 1 PM Session - ML Overview

Please refer back to [2024 repository](https://github.com/seanlam74/GMS5204)

Files in GitHub:

1. `Lab2_1_Clustering_CKD.ipynb`: contains script for hands-on lab 1 - unsupervised learning
   - chronic_kidney_disease_full_unclean.csv contains dataset for cleaning.
   - chronic_kidney_disease_full.csv contains original CKD dataset.
   - Data Source: [Chronic Kidney Disease Dataset](https://archive.ics.uci.edu/ml/datasets/chronic_kidney_disease)


2. `Lab2_2_Supervised_HF.ipynb`: contains script for hands-on lab 2 - supervised learning
   - Dataset: heart_failure_clinical_records_dataset.csv
   - Reference: Chicco, D., Jurman, G. Machine learning can predict survival of patients with heart failure from serum creatinine and ejection fraction alone. BMC Med Inform Decis Mak 20, 16 (2020). https://doi.org/10.1186/s12911-020-1023-5
