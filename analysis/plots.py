import pandas as pd
# from bokeh.models import HoverTool
from bokeh.plotting import figure, show, output_file
from bokeh.charts import Scatter, HeatMap

# read metadata about the performaces
metadata = pd.read_csv("../metadata/metatone-performance-information.csv",
                       index_col='time', parse_dates=True)

def read_gesture_csv(filename):
  """
  read in the data for a specific performance
  """
  csv_path = "../data/" + filename + "-touches-posthoc-gestures.csv"
  df = pd.read_csv(csv_path, index_col='time', parse_dates=True)
  df.insert(0, 'session', filename)
  # use "melted" format - useful for Bokeh plotting
  # df = pd.melt(df, id_vars='time', var_name='musician', value_name='gesture')
  return df

# futzing about

x = read_gesture_csv("2013-04-20T14-55-00-MetatoneOSCLog")

y = [read_gesture_csv(f) for f in metadata['filename']]

x.merge(metadata, on='filename') # it's aliiiiive!

grouped = metadata.groupby('filename')

grouped.agg(read_gesture_csv)

# TODO use multiindexes - http://pandas.pydata.org/pandas-docs/stable/advanced.html
