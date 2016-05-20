# Metatone Analysis Project

![Three performances that are recorded in this repository.](https://raw.githubusercontent.com/anucc/metatone-analysis/master/images/three-performance-contexts.jpg)

This repository contains data from collaborative touch-screen performances on iPads that were recorded from 2013-2015 as well as scripts in R and Python for performing statistical analysis on these performances.

The `metatone_post_hoc_analysis.py` file will perform gestural classification on these performance logs, and measure the transition probabilities between these gestures.

## Important files:

- `data` contains the touch-screen data and post-hoc gestural classifications for each performance in the archive.

- `metatone-performance-information.csv` contains meta-data about each performance included in the repository.

- `metatone_post_hoc_analysis.py` is the main analysis script.

- `metatone-performance-data.csv` is the output file from the analysis script and contains flux and entropy measures on the transition matrices of each performance.
