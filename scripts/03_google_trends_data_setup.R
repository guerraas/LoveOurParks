# set up relative trends data and shapefiles

# load shapefiles


l48_shp <- st_read(here("data","shapefiles","lower_48_shape.shp"))
ak_shp <- st_read(here("data","shapefiles","alaska_shape.shp"))
hi_shp <- st_read(here("data","shapefiles","hawaii_shape.shp"))

#standardize state names
l48_shp$state <- tolower(l48_shp$NAME) 
ak_shp$state <- tolower(ak_shp$NAME)
hi_shp$state <- tolower(hi_shp$NAME)

#list of csv files in the relative trends folder
csv_paths <- list.files(path = here("data","googletrends_relative"), 
                        pattern = "*.csv", 
                        full.names = TRUE)

#empty lsit for dfs
df_list <- list()

# Loop through each file
for (i in seq_along(csv_paths)) {
  # Get the current file path
  file_path <- csv_paths[i]
  
  # Extract year from filename
  year <- str_extract(file_path, "\\d{4}")
  
  # Read the CSV file
  current_df <- read.csv(file_path)
  
  # Add year column
  current_df$year <- year
  
  # Add to list
  df_list[[i]] <- current_df
}

# Combine all dataframes
GTrelative_df <- bind_rows(df_list)
rm(df_list)

#clean up relative df time period column (split into two)
GTrelative_df <- GTrelative_df %>% 
  separate(time_period, into = c("timeperiod_start", "timeperiod_end"),sep=" ") %>% 
  mutate(timeperiod_start = as.POSIXct(timeperiod_start), 
         timeperiod_end = as.POSIXct(timeperiod_end), 
         year = as.numeric(year), 
         state = trimws(state),
         state = tolower(state))


##### get timeseries data for each state

states_meta <- data.frame(name = state.name, abb = state.abb) #get state names from state code

GTtime_df <- read_csv(here("data","googletrends_nps_state_trends.csv")) %>% 
  separate(State, into = c("code","STUSPS"),sep="-") %>%  
  mutate(date = as.POSIXct(Date)) %>% 
  dplyr::select(-c(Date, code)) %>% 
  left_join(states_meta, by=c("STUSPS" = "abb")) %>% 
  rename(state = name) %>% 
  mutate(
  state = tolower(state))
  
