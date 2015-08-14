#! /usr/bin/env python
# pylint: disable=line-too-long
"""
Loads up ALL metatone performance touch logs and calculates some performance statistics.
"""
from __future__ import print_function
import os
import pandas as pd
import numpy as np
import time
import datetime
import sys
sys.path.append("MetatoneClassifier/classifier/")
sys.path.append("MetatoneClassifier/performance-plotter/")
import metatone_classifier
import transitions
import PlotMetatonePerformanceAndTransitions

class MetatoneTouchLog:
    """
    Class to contain dataframes of a single metatone performance logs.
    Must be initialised with a log_path.
    """
    def __init__(self, touches_file):
        #print("Loading logs for " + touches_file)
        performance_path = touches_file.replace(".csv", "")
        self.performance_title = touches_file.replace("-touches.csv", "").replace("data/", "")
        self.touches = pd.read_csv(touches_file, index_col='time', parse_dates=True)
        # load up the gestures or generate if necessary.
        gestures_path = performance_path + "-posthoc-gestures.csv"
        if (os.path.isfile(gestures_path)):
            self.gestures = pd.read_csv(gestures_path, index_col='time', parse_dates=True)
        #else:
            #print("No gesture file.")
            # generate the gestures!

    def first_touch_timestamp(self):
        """
        Returns the timestamp of the first touch.
        """
        return self.touches[:1].index[0]

    def performers(self):
        """
        Returns the list of performers in this performance
        """
        return self.touches['device_id'].unique()

    def number_performers(self):
        """
        Returns the list of performers in this performance
        """
        return len(self.touches['device_id'].unique().tolist())

        # self.events = pd.read_csv(performance_path + EVENTS_PATH, index_col='time', parse_dates=True)
        # self.raw_new_ideas = self.events[self.events["event_type"] == "new_idea"]["event_type"].count()
        # self.screen_change_new_ideas = self.count_new_idea_interface_changes()
        # self.transitions = pd.read_csv(performance_path + TRANSITIONS_PATH, index_col='time', parse_dates=True)
        # self.metatone = pd.read_csv(performance_path + METATONE_PATH, index_col='time', parse_dates=True)
        # self.online = pd.read_csv(performance_path + ONLINE_PATH, index_col='time', parse_dates=True)
        # self.ensemble_transition_matrix = transitions.calculate_full_group_transition_matrix(self.gestures)
        # self.ensemble_transition_matrix = transitions.transition_matrix_to_stochastic_matrix(self.ensemble_transition_matrix)


def main():
    """Load up all the performances and do some stats"""
    log_files = []
    performances = []
    for local_file in os.listdir("data"):
        if local_file.endswith("-touches.csv"):
            log_files.append("data/" + local_file)
    print("Loading the performances.")
    for log in log_files:
        performances.append(MetatoneTouchLog(log))

    ## Also load up the experiment design dataframe to merge with the data!
    performance_information = pd.read_csv("metatone-performance-information.csv", index_col='time', parse_dates=True)

    perf_names = {}
    for perf in performances:
        perf_names.update({perf.first_touch_timestamp():{
            "filename":perf.performance_title,
            "number_performers": perf.number_performers()
            }})
    perf_frame = pd.DataFrame.from_dict(perf_names, orient="index")
    perf_frame.to_csv("performance-names.csv")

    # print("Finding the lengths.")
    # performer_length_dict = {}
    # for perf in performances:
    #     performer_length_dict.update(perf.performer_lengths())
    # performance_length_frame = pd.DataFrame.from_dict(performer_length_dict, orient="index")
    # performance_length_frame['time'] = performance_length_frame.index
    # performers = performances[0].performers().tolist()
    # long_performance_lengths = pd.melt(performance_length_frame, id_vars=['time'], value_vars=performers)
    # long_performance_lengths = long_performance_lengths.replace({'variable':DEVICE_SEATS})
    # long_performance_lengths.to_csv("performance_lengths.csv")

    # print("Creating Gesture Scores.")
    # for perf in performances:
    #     perf.print_gesture_score() ## Prints out a gesture-score pdf for reference.

    # print("Creating performance info dataframe.")
    # perf_data = {}
    # for perf in performances:
    #     perf_data.update({perf.first_touch_timestamp():{
    #         "raw_new_ideas":perf.raw_new_ideas,
    #         "new_idea_changes":perf.count_new_idea_interface_changes(),
    #         "button_presses":perf.count_button_interface_changes(),
    #         "flux":perf.ensemble_flux(),
    #         "entropy":perf.ensemble_entropy()
    #     }})
    # performance_data = pd.DataFrame.from_dict(perf_data, orient = "index")
    # performance_data.to_csv("performance_data.csv")

    # print("Creating perfomer button press dataframe")
    # performer_presses = {}
    # for perf in performances:
    #     performer_presses.update(perf.button_interface_changes_by_performer())
    # button_changes_frame = pd.DataFrame.from_dict(performer_presses,orient = "index")
    # button_experiment_frame = pd.concat([experiment_design,button_changes_frame], axis = 1)
    # performers = performances[0].performers().tolist()
    # button_experiment_frame['time'] = button_experiment_frame.index

    # long_button_frame = pd.melt(button_experiment_frame, id_vars=['time', 'perf_number', 'group', 'performance', 'button', 'server', 'overall'],
    #     value_vars=performers,
    #     var_name='seat',
    #     value_name='button_presses')
    # long_button_frame = long_button_frame.replace({'seat':DEVICE_SEATS})
    # long_button_frame['performer'] = np.vectorize(lambda x, y: PARTICIPANTS[x][y])(long_button_frame['group'], long_button_frame['seat'])
    # long_button_frame.to_csv("button_presses_per_performer.csv")

if __name__ == '__main__':
    main()
