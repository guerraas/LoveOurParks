# U.S. National Parks: interest and visitation by state and season

*Ana Sofia Guerra, PhD - Pelagos Research & Analytics*

The purpose of this repo is to create a Shiny app that explores visualizing interest in U.S. National Parks over time using park visitation data and Google trends data.

<https://pelagos-analytics.shinyapps.io/LoveNationalParks/>

The Shiny app is made in R, sourcing the Google trends data is done in python.

## Structure

### scripts

The script for running the app is `app.R`, all ofther scripts are in the *scripts* folder.

-   `00_google_trends_set.py`: used for using the `pytrends` web-scraping API to get Google trends data on keyword and timeframe of choice. This script sources two other scripts, `01_grends_state_timeseries.py` and `02_gtrends_states_relative.py`, which run the API for timeseries trend data by state and trend data comparing states, respectively.

-   `00_shapefiles.R`: run this to download shapefiles for U.S. states

-   `app.R` runs the app and reads in `03_google_trends_data_setup.R`, `04_NPS_irma_data_setup.R`, `05_data_analysis_visitation.R`, which provide data set up, clean up, and summaries, using relative paths.

### data

Due to size, data are not contained in the repo; however can be shared upon request, or by using the API and manual IRMA query. For the R project, all data is stored within the `data` folder and referenced using relative paths.

#### Structure

`data:`

-   `googletrends_nps_state_trends.csv`

-   `NPS_ITRMA_publicuse_20192024.csv`

-   `NPS-Acreage-03-31-2024.csv`

-   `googletrends_relative`:

    -   `nps_states_relative_t_2019.csv`

    -   `nps_states_relative_t_2020.csv`

    -   `nps_states_relative_t_2021.csv`

    -   `nps_states_relative_t_2022.csv`

    -   `nps_states_relative_t_2023.csv`

    -   `nps_states_relative_t_2024.csv`

    -   `nps_states_relative_t_2025.csv`

-   `shapefiles`:

    -   `alaska_shape.shp`

    -   `hawaii_shape.shp`

    -   `lower_48_shape.shp`

The data are sourced from two separate places:

-   Google trends data using a web-scraping API in python (`pytrends`) <https://trends.google.com>

-   National Parks visitation data from the IRMA Database for NPS Visitation: <https://irma.nps.gov>
