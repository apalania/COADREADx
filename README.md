# Welcome to COADREADx
[![DOI](https://zenodo.org/badge/809892599.svg)](https://zenodo.org/doi/10.5281/zenodo.13790219)
The ultimate goal is the development of diagnostic and prognostic models (so-called "Software-as-Medical-Devices") toward expediting the early-stage detection and risk stratification of colorectal cancer. This is a work in constant progress. Please note that the content of this research code repository is not intended to be a medical device yet, nor ready for clinical use of any kind, including diagnosis or prognosis.

The following source code is made available here:
1. ModDev1.R: Development of the Screening model for colorectal cancer
2. ScreeningModel_RF_FullData.rds: Screening model object-file (.rds) that could be loaded in R to make predictions on new instances from patient data. The model has been re-trained on the full available data
3. PrognosticModel.rds: Object-file (.rds) of the developed prognostic model that could be loaded in R for risk predictions on new instances from patient data.
4. app.R: Shiny app code for the COADREADx webserver. The models have been included in the webserver for web-accessible predictions.

For the dataset and other supplementary information, please consult:
[COADREADx on Figshare](https://doi.org/10.6084/m9.figshare.20489211.v4)

### Webserver
[COADREADx](https://apalanialab.shinyapps.io/coadreadx/)

### Citation
Ashok Palaniappan*, Sangeetha Muthamilselvan, Arjun Sarathi. (2024) COADREADx: A comprehensive algorithmic dissection unravels salient biomarkers and actionable insights into the discrete progression of colorectal cancer. medRxiv 2022.08.16.22278877; doi: https://doi.org/10.1101/2022.08.16.22278877 [submitted]

### License 
The code in this repository, including all code samples in the scripts listed above, is released under the BSD 3-Clause License. Read more at the [Open Source Initiative](https://opensource.org/licenses/MIT).

### For more information
Contact [Ashok Palaniappan](mailto:apalania@scbt.sastra.edu)
