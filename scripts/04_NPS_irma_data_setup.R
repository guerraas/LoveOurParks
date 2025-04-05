# NPS Vistation data from irma.nps.gov monthly for 2019-2024

####### DATA LOAD ########

#get area in sq km for each state. See 00_shapefiles. 
states_area <- st_read(here("data","shapefiles","us_states_shape.shp")) %>% 
  mutate(state_land = round((ALAND / 1e6),2),# ALAND = land area in square meters
         state = tolower(NAME),
         state_code = STUSPS) %>% #convert to km sq
  dplyr::select(state, state_land) %>% 
  st_drop_geometry()

#metadata from R base package, join state area
states_meta <- data.frame(name_cap = state.name, state_code = state.abb) %>% 
  mutate(state = tolower(name_cap)) %>% 
  left_join(states_area, by="state")

# season data from google trends dataframe
seasons <- GTrelative_df %>% 
  dplyr::select(timeperiod_start, timeperiod_end, season) %>% 
  distinct() %>% 
  mutate(start=as.Date(timeperiod_start),
         end = as.Date(timeperiod_end)) %>% 
  dplyr::select(start, end, season)

# visitation data
nps_visit <- read_csv(here('data','NPS_IRMA_publicuse_20192024.csv')) %>% 
  mutate(date = as.Date(sprintf("%d-%02d-01", Year, Month))) %>% #create date column
  dplyr::select(ParkName,State,date,RecreationVisits,Region,ParkType) %>% #select relevant columns
  rename(state_code = State, visits = RecreationVisits)
  
# park size, join with states meta
nps_area <- read_csv(here('data','NPS-States-Acreage-03-31-2024.csv')) %>% 
  dplyr::select(State, `NPS Fee Acres`) %>% 
  rename(acres=`NPS Fee Acres`) %>% 
  group_by(State) %>% 
  summarise(nps_acres = sum(acres))  %>% #total fee acres by state
  mutate(state = tolower(State),
         nps_area = round(nps_acres * 0.00404686),2) %>% #convert acres to sq km
  dplyr::select(state, nps_area) 

############## DATA MERGING AND SET UP #####

## park relevant data per state: number of parks, park fee acreage
## join with states_meta
nps_state_data <- nps_visit %>% 
  distinct(ParkName, state_code) %>% 
  group_by(state_code) %>% 
  summarise(num_parks = n()) %>% 
  left_join(states_meta, by="state_code") %>% 
  drop_na(state) %>% 
  left_join(nps_area, by="state") %>% 
  dplyr::select(state, state_code, nps_area, state_land, num_parks)


## combine visitation by acres to standardize
nps_visit_adj <- nps_visit %>% 
  group_by(state_code, date) %>% 
  summarise(tot_visits = sum(visits)) %>% 
  left_join(nps_state_data, by="state_code") %>% #join in state nps data
  mutate(
    park_density = num_parks / state_land, #parks per sq km
    visit_p_park = tot_visits / num_parks, #visits per park
    visit_score = (park_density + visit_p_park)/2,
    date = as.POSIXct(date),
    date1 = as.Date(date)) %>%  #date format 
  drop_na() %>% 
  fuzzy_left_join(seasons,
                  by = c("date1" = "start", "date1" = "end"),
                  match_fun = list(`>=`, `<=`)) %>% # add in season data 
  pivot_longer(c(park_density,visit_p_park,visit_score), names_to = "visit_metric", values_to = "visit_value")
  




