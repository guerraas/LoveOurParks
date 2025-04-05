

####################################################
#### Interest over time for each state 
####################################################


# Initialize pytrends
pytrends = TrendReq(hl='en-US', tz=360)


####### GET LIST OF STATES ###########

#no specific category, within 5 years, only in US, for web searches
#the timeframe here is less important, just using this for the list of states 
pytrends.build_payload(keyword, 
                       cat=0, 
                       timeframe = period, 
                       geo="US", 
                       gprop="") 
# interest by states (relative to each other)                       
df_states = pytrends.interest_by_region(resolution="REGION", inc_low_vol=True, inc_geo_code=True)
df_states = df_states.reset_index()  # Ensure "region" is a column

######### STATE LOOP

states = df_states['geoCode'].unique()  # Get state codes (e.g., 'US-WA', 'US-CA')

state_trends = {}

for state in states:
    pytrends.build_payload(keyword, timeframe=period, geo=state)
    df = pytrends.interest_over_time().drop(columns=['isPartial'], errors='ignore')
    
    if not df.empty:
        state_trends[state] = df  # Store the data

# convert to a single DataFrame
df_state_trends = pd.concat(state_trends, names=["State", "Date"]).reset_index()
df_columns = df_state_trends.columns.tolist() #list columns

# trends output gives the keyword as column name, but want to change the name at index 2 (third column)
df_columns[2] = 'interest'

# Assign the updated column names back to the DataFrame
df_state_trends.columns = df_columns

output_path = os.path.join("data", df_filename_trends)
df_state_trends.to_csv(output_path, index=False)

