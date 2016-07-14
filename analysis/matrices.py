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

def mle_transition_probs(series):
  df = pd.DataFrame({"from": series, "to": series.shift(-1)})
  # aggregate counts for each transition
  df = df.groupby(['from','to']).size().reset_index(name='count')
  return df




# futzing about

x = read_session_data("2013-04-20T14-55-00-MetatoneOSCLog")

x.christina.astype("category", categories=gestures, ordered=False)

y = [read_session_data(f) for f in metadata['filename']]

x.merge(metadata, on='filename') # it's aliiiiive!

grouped = metadata.groupby('filename')

grouped.agg(read_session_data)


[k for {k: v} in {"B": 1, "C": 5}]
