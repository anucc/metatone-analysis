"""
Split up a touch frame into chunks separated by 30s of inactivity.
"""
from __future__ import print_function
import os
import pandas as pd
import numpy as np
import time
import datetime
touches = pd.read_csv("../data/2013-04-20T14-55-00-MetatoneOSCLog-touches-posthoc-gestures.csv", index_col='time', parse_dates=True)
touches["timediff"] = touches.index
touches["timediff"] = touches["timediff"] - touches["timediff"].shift()
long_break = touches.ix[touches["timediff"] > pd.to_timedelta("00:02:00")]
#touches.ix[touches.index.indexer_between_time(long_break.index[1],long_break.index[2])]
first_touch = touches[:1].index[0]
frame_list = []
for last_touch in long_break.index:
    part_frame = touches.ix[touches.index.indexer_between_time(first_touch,last_touch)]
    first_touch = last_touch
    frame_list.append(part_frame[:-1]) ## this makes it left closed, right open
    
# then add the rest:
last_touch = touches.index[-1]
part_frame =  touches.ix[touches.index.indexer_between_time(first_touch,last_touch)] #inclusive
frame_list.append(part_frame) ## the last one is closed on both sides!

# now write each one to csv. (forget about the time_diff column)
for frame in frame_list:
    frame_name = frame.index[0].strftime('%Y-%m-%dT%H-%M-%S') + "-MetatoneOSCLog-autosplit-touches.csv"
    frame[['device_id','x_pos','y_pos','velocity']].to_csv(frame_name)
