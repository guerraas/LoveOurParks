

####################################################
#### Interest by season for all states (relative to each other)
####################################################
### STATES RELATIVE INTEREST

# Create empty dataframe to store results


# Define seasonal time periods from 2019 to current (early 2025)
t_2019 = [
    # 2019
    ("2019-03-01 2019-05-31", "Spring 2019"),
    ("2019-06-01 2019-08-31", "Summer 2019"),
    ("2019-09-01 2019-11-30", "Fall 2019"),
    ("2019-12-01 2020-02-29", "Winter 2019-20")
]

t_2020 = [
    # 2020
    ("2020-03-01 2020-05-31", "Spring 2020"),
    ("2020-06-01 2020-08-31", "Summer 2020"),
    ("2020-09-01 2020-11-30", "Fall 2020"),
    ("2020-12-01 2021-02-28", "Winter 2020-21")
]

t_2021 = [
    # 2021
    ("2021-03-01 2021-05-31", "Spring 2021"),
    ("2021-06-01 2021-08-31", "Summer 2021"),
    ("2021-09-01 2021-11-30", "Fall 2021"),
    ("2021-12-01 2022-02-28", "Winter 2021-22")
]

t_2022 = [
    # 2022
    ("2022-03-01 2022-05-31", "Spring 2022"),
    ("2022-06-01 2022-08-31", "Summer 2022"),
    ("2022-09-01 2022-11-30", "Fall 2022"),
    ("2022-12-01 2023-02-28", "Winter 2022-23")
]

t_2023 = [    
    # 2023
    ("2023-03-01 2023-05-31", "Spring 2023"),
    ("2023-06-01 2023-08-31", "Summer 2023"),
    ("2023-09-01 2023-11-30", "Fall 2023"),
    ("2023-12-01 2024-02-29", "Winter 2023-24")
]
  
t_2024 = [
    ("2024-03-01 2024-05-31", "Spring 2024"),
    ("2024-06-01 2024-08-31", "Summer 2024"),
    ("2024-09-01 2024-11-30", "Fall 2024"),
    ("2024-12-01 2025-02-28", "Winter 2024-25")
]

t_2025 = [    
    # 2025 (partial)
    ("2025-03-01 2025-03-21", "Spring 2025 (partial)")
]

#dictionary with all the year bins
year_bins = {
    "t_2019": t_2019,
    "t_2020": t_2020,
    "t_2021": t_2021,
    "t_2022": t_2022,
    "t_2023": t_2023,
    "t_2024": t_2024,
    "t_2025": t_2025
}

for year_name, time_periods in year_bins.items():
    # create empty dataframe for this year
    all_states_data = pd.DataFrame()
    
    print(f"Processing {year_name}...")
    
    # loop through time periods for this year
    for period, label in time_periods:
        try:
            # Build payload for this time period
            pytrends.build_payload(keyword, timeframe=period, geo='US')
            
            # Get interest by region for this time period
            state_data = pytrends.interest_by_region(resolution='REGION', inc_low_vol=True)
            
            # Add time period as a column
            state_data['time_period'] = period
            state_data['season'] = label
            
            # Append to dataframe
            all_states_data = pd.concat([all_states_data, state_data])
            
            print(f"  Processed {label}")
            
        except Exception as e:
            print(f"  Error processing {label}: {e}")
        
        # Add a small delay to avoid rate limiting otherwise throws 429 error after a while
        time.sleep(1)
    
    # Save if not empty
    if not all_states_data.empty:
        # Reset index 
        all_states_data = all_states_data.reset_index().rename(columns={'index': 'state'})
        df_columns = all_states_data.columns.tolist() #list columns

    # trends output gives the keyword as column name, but want to change the name at index 1 (2nd column)
        df_columns[1] = 'interest'

# Assign the updated column names back to the DataFrame
        all_states_data.columns = df_columns
        # Save CSV for this year
        df_filename = df_filename_relative + year_name
        output_path = os.path.join("data","relative", df_filename)
        all_states_data.to_csv(output_path, index=False)
        
        print(f"Saved {output_path}")
    else:
        print(f"No data to save for {year_name}")
    
