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
sys.path.append("minirank")
import metatone_classifier
import transitions
import PlotMetatonePerformanceAndTransitions
import generate_posthoc_gesture_score
from minirank import *
from sklearn import datasets, metrics, cross_validation
import matplotlib.pyplot as plt

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
        else:
            print("Gesture Frame not found, now generating: " + gestures_path)
            self.gestures = generate_posthoc_gesture_score.generate_gesture_frame(self.touches)
            self.gestures.to_csv(gestures_path)
        self.ensemble_transition_matrix = transitions.calculate_full_group_transition_matrix(self.gestures)
        self.ensemble_transition_matrix = transitions.transition_matrix_to_stochastic_matrix(self.ensemble_transition_matrix)
        self.longest_break = self.find_longest_breaks()

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

    def ensemble_flux(self):
        """
        Returns the flux of the whole ensemble transition matrix.
        """
        return transitions.flux_measure(self.ensemble_transition_matrix)

    def ensemble_entropy(self):
        """
        Returns the entropy of the whole ensemble transition matrix.
        """
        return transitions.entropy_measure(self.ensemble_transition_matrix)

    def performance_length(self):
        """
        Returns the total length of the performance (first touch to last touch)
        """
        first_touch = self.touches[:1].index[0].to_datetime()
        last_touch = self.touches[-1:].index[0].to_datetime()
        return (last_touch - first_touch).total_seconds()

    def performer_lengths(self):
        """
        Returns the individual performers' performance lengths
        """
        performers = self.performers()
        first_touch = self.touches[:1].index[0].to_datetime()
        performer_first_touches = {}
        performer_last_touches = {}
        performance_lengths = {}
        for performer_id in performers:
            performer_touches = self.touches.ix[self.touches['device_id'] == performer_id]
            performer_first_touches[performer_id] = performer_touches[:1].index[0].to_datetime()
            performer_last_touches[performer_id] = performer_touches[-1:].index[0].to_datetime()
            performer_length = (performer_touches[-1:].index[0].to_datetime() - first_touch).total_seconds()
            performance_lengths[performer_id] = performer_length
            # print("Performer: " + performer_id + " Length was: " + str(performer_length))
        return {self.first_touch_timestamp():performance_lengths}

    def print_gesture_score(self):
        """
        Prints a gesture-score using the script procedure
        """
        performance_time = time.strptime(self.performance_title[:19], '%Y-%m-%dT%H-%M-%S')
        plot_title = time.strftime('%Y-%m-%dT%H-%M-%S', performance_time) + "-gesture-plot"
        PlotMetatonePerformanceAndTransitions.plot_gesture_only_score(plot_title, self.gestures)
        print("Saved gesture plot: " + plot_title)
        
    def find_long_breaks(self):
        """
        Finds breaks longer than 2 minutes in a touch log. Prints a warning!
        """
        self.touches["timediff"] = self.touches.index
        self.touches["timediff"] = self.touches["timediff"] - self.touches["timediff"].shift()
        long_break = self.touches.ix[self.touches["timediff"] > pd.to_timedelta("00:03:00")]
        if not long_break.empty:
            print("WARNING: Long Break in Performance: " + self.performance_title)
            print("Printing autosplit touch files.")
            print(str(long_break["timediff"]))
            first_touch = self.touches[:1].index[0]
            frame_list = []
            for last_touch in long_break.index:
                part_frame = self.touches.ix[self.touches.index.indexer_between_time(first_touch,last_touch)]
                first_touch = last_touch
                frame_list.append(part_frame[:-1]) ## this makes it left closed, right open
            # then add the rest:
            last_touch = self.touches.index[-1]
            part_frame = self.touches.ix[self.touches.index.indexer_between_time(first_touch,last_touch)] #inclusive
            frame_list.append(part_frame) ## the last one is closed on both sides!
            # now write each one to csv. (forget about the time_diff column)
            for frame in frame_list:
                frame_name = frame.index[0].strftime('%Y-%m-%dT%H-%M-%S') + "-MetatoneOSCLog-autosplit-touches.csv"
                frame[['device_id','x_pos','y_pos','velocity']].to_csv(frame_name)
        return 0

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
    print("Loading performance information frame.")
    performance_information = pd.read_csv("metatone-performance-information.csv", index_col='time', parse_dates=True)

    print("Generating the performance data frame.")
    perf_names = {}
    for perf in performances:
        perf_names.update({perf.first_touch_timestamp():{
            "filename":perf.performance_title,
            "number_performers": perf.number_performers(),
            "length_seconds": perf.performance_length(),
            "flux": perf.ensemble_flux(),
            "entropy": perf.ensemble_entropy()
            }})
    perf_frame = pd.DataFrame.from_dict(perf_names, orient="index")
    perf_frame = pd.concat([performance_information,perf_frame], axis = 1)
    #perf_frame['performance_context','performance_type','instruments','notes','video_location'] = performance_information['performance_context','performance_type','instruments','notes','video_location']
    perf_frame.to_csv("metatone-performance-data.csv")

    print("Creating Gesture Scores.")
    for perf in performances:
        perf.print_gesture_score() ## Prints out a gesture-score pdf for reference.

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

    # loading the survey data
    # 2014 - Q1 was performance quality
    performance_surveys_2014 = pd.read_csv("data-surveys/201407-Study.csv",index_col='time', parse_dates=True)
    # 2015 runthrough - Q26
    performance_surveys_2015_runthrough = pd.read_csv("data-surveys/201504-Study-RunthroughData.csv",index_col='time', parse_dates=True)
    # 2015 study - Q23
    performance_surveys_2015_study = pd.read_csv("data-surveys/201504-Study-PerformanceSurveys.csv",index_col='time', parse_dates=True)

    # a.apply(lambda x: LIKERT_MAPPING[x])
    LIKERT_MAPPING = {1:1,2:1,3:2,4:2,5:3,6:4,7:4,8:5,9:5}
    #ratings = performance_surveys_2014["Q1"]
    #ratings = ratings.append(performance_surveys_2015_runthrough["Q26"].apply(lambda x: LIKERT_MAPPING[x]))
    #ratings = ratings.append(performance_surveys_2015_study["Q23"].apply(lambda x: LIKERT_MAPPING[x]))
    #flux_ratings_frame = perf_frame['flux']
    #flux_ratings_frame = pd.concat([flux_ratings_frame,ratings],axis =1)

    #ratings = performance_surveys_2014["Q6"]
    #flux_entropy_ratings = flux_entropy_ratings.dropna()

    #flux_entropy_ratings = pd.DataFrame({"rating":ratings})
    #flux_entropy_ratings["flux"] = perf_frame["flux"]
    #flux_entropy_ratings["entropy"] = perf_frame["entropy"]
    #flux_entropy_ratings.to_csv("flux_entropy_ratings.csv")

def test_regression(df):
    """
    using the logistic ordinal regression package from:
    http://fa.bianp.net/blog/2013/logistic-ordinal-regression/
    """
    X, y = np.array(df[["flux","entropy"]]), np.array(df["rating"])
    #X, y = np.array(df["flux"]), np.array(df["rating"])

    #X -= X.mean()
    #y -= y.min()

    idx = np.argsort(y)
    X = X[idx]
    y = y[idx]
    cv = cross_validation.ShuffleSplit(y.size, n_iter=50, test_size=.1, random_state=0)
    score_logistic = []
    score_ordinal_logistic = []
    score_ridge = []
    for i, (train, test) in enumerate(cv):
        if not np.all(np.unique(y[train]) == np.unique(y)):
            # we need the train set to have all different classes
            continue
        assert np.all(np.unique(y[train]) == np.unique(y))
        train = np.sort(train)
        test = np.sort(test)
        w, theta = ordinal_logistic_fit(X[train], y[train])
        pred = ordinal_logistic_predict(w, theta, X[test])
        s = metrics.mean_absolute_error(y[test], pred)
        print('ERROR (ORDINAL)  fold %s: %s' % (i+1, s))
        score_ordinal_logistic.append(s)

        from sklearn import linear_model
        clf = linear_model.LogisticRegression(C=1.)
        clf.fit(X[train], y[train])
        pred = clf.predict(X[test])
        s = metrics.mean_absolute_error(y[test], pred)
        print('ERROR (LOGISTIC) fold %s: %s' % (i+1, s))
        score_logistic.append(s)

        from sklearn import linear_model
        clf = linear_model.Ridge(alpha=1.)
        clf.fit(X[train], y[train])
        pred = np.round(clf.predict(X[test]))
        s = metrics.mean_absolute_error(y[test], pred)
        print('ERROR (RIDGE) fold %s: %s' % (i+1, s))
        score_ridge.append(s)
    print()
    print('MEAN ABSOLUTE ERROR (ORDINAL LOGISTIC):    %s' % np.mean(score_ordinal_logistic))
    print('MEAN ABSOLUTE ERROR (LOGISTIC REGRESSION): %s' % np.mean(score_logistic))
    print('MEAN ABSOLUTE ERROR (RIDGE REGRESSION):    %s' % np.mean(score_ridge))



def plot_confusion_matrix(cm, title='Confusion matrix', cmap=plt.cm.Blues):
    plt.imshow(cm, interpolation='nearest', cmap=cmap)
    plt.title(title)
    plt.colorbar()
    tick_marks = np.arange(len(iris.target_names))
    plt.xticks(tick_marks, iris.target_names, rotation=45)
    plt.yticks(tick_marks, iris.target_names)
    plt.tight_layout()
    plt.ylabel('True label')
    plt.xlabel('Predicted label')

if __name__ == '__main__':
    main()
