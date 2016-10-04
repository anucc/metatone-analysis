from bokeh.charts import HeatMap, output_file, show
import pandas as pd

df.reset_index(inplace=True)

hm = HeatMap(df, y='from', x='to', values='christina', title='TM', stat=None)

output_file('heatmap.html', mode='inline')
show(hm)
