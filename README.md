# Metatone Touch-Screen Performance Analysis

![Three performances that are recorded in this repository.](https://raw.githubusercontent.com/anucc/metatone-analysis/master/images/three-performance-contexts.jpg)

[![DOI](https://zenodo.org/badge/20166/anucc/metatone-analysis.svg)](https://zenodo.org/badge/latestdoi/20166/anucc/metatone-analysis)

This repository contains data from collaborative touch-screen
performances on iPads that were recorded from 2013-2015 as well as
scripts in R and Python for performing statistical analysis on these
performances.

## Important files:

- `data` contains the touch-screen data and post-hoc gestural
  classifications for each performance in the archive
- `metadata` contains meta-data about each performance included in the
  repository
- `analysis` contains python scripts for generating & plotting the
  transition sequences
  - `metatone_post_hoc_analysis.py` is the main analysis script, which
    performs gestural classification on these performance logs, and
    measure the transition probabilities between these gestures
  - `metatone-performance-data.csv` is the output file from the
    analysis script and contains flux and entropy measures on the
    transition matrices of each performance.
- legacy analysis scripts are in `R`

## Jupyter Notebooks

Some jupyter notebooks in the top level of the repository (e.g., `generate_metatone_tinyperf_corpus_differential.ipynb`) are used to transform the corpus data and use for other projects.
