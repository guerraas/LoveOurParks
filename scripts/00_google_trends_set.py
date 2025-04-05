
### GOOGLE SEARCH TRENDS OVER TIME AND BY STATE ####

import runpy
import pandas as pd
from pytrends.request import TrendReq
from datetime import datetime
import time


### SET PARAMETERS AND FILE NAMES F
### Define keyword and timeframe of interest
keyword = ["national park"] #google trends queries are case insensitive

period = ["2019-01-01 2025-03-10"] #period of interest

#name for df outputs, with a code or something to remember the keyword
#trends is the time series for each state, relative is interest comparing states over time
df_filename_trends = ["nps_state_trends.csv"] 

df_filename_relative = ["nps_state_relative.csv"] 



runpy.run_path('01_gtrends_state_timeseries.py')
runpy.run_path('02_gtrends_states_relative.py')
