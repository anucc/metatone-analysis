import pandas as pd
# from bokeh.models import HoverTool
from bokeh.plotting import figure, show, output_file
from bokeh.charts import Scatter

# filenames = ["../data/" + f
#              for f in os.listdir("../data")
#              if f.endswith("-touches-posthoc-gestures.csv")]

metadata = pd.read_csv("../metadata/metatone-performance-information.csv",
                       index_col='time', parse_dates=True)

# we'll build a big fat DataFrame with all the trimmings
def metatone_df_from_filename(filename):
  """
  read in the data for a specific performance
  """
  csv_path = "../data/" + filename + "-touches-posthoc-gestures.csv"
  return pd.read_csv(csv_path, index_col='time', parse_dates=True)

# TODO use multiindexes - http://pandas.pydata.org/pandas-docs/stable/advanced.html
