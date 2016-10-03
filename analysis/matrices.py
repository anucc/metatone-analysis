# pip install git+git://github.com/riccardoscalco/Pykov@master
import pykov as pk
import numpy as np
import pandas as pd

# read metadata about the performaces
metadata = pd.read_csv("../metadata/metatone-performance-information.csv",
                       index_col='time', parse_dates=True)

gestures = ["N", "FT", "ST", "FS", "FSA", "VSS", "BS", "SS", "C"]

def add_gesture_labels(series):
  """
  replace integer labels with meaningful gesture labels
  """
  series = series.astype("category")
  series.cat.categories = gestures
  return series

def read_session_data(session_name):
  """
  read in the data for a specific performance
  """
  csv_path = "../data/" + session_name + "-touches-posthoc-gestures.csv"
  df = pd.read_csv(csv_path, index_col='time', parse_dates=True)
  return df.apply(add_gesture_labels)

# Gosh, I wish this wasn't still so filthy - there's gotta be a nicer
# numpy/scipy/pandas way to do this. Still, bird in the hand and all
# that...

def mle_transition_counts(series):
  df = pd.DataFrame({"from": series, "to": series.shift(-1)})
  # aggregate counts for each transition
  df = df.groupby(['from','to']).size()
  return df

def melted_mle_transition_counts(session_df):
  return session_df.apply(mle_transition_counts).fillna(0.)

df = melted_mle_transition_counts(read_session_data("2013-04-20T14-55-00-MetatoneOSCLog"))
