"""
Transition Module for Metatone Analysis Repo
Charles Martin 2016

So far:

-- copied in functions used in metatone_analysis

To do:

-- create function to calculate transition matrices for multiple performers
-- work on calculations of divisions of performances (maybe 1-pole, 2-pole, etc)

"""
from __future__ import print_function
import pandas as pd
import numpy as np
from scipy.stats import entropy
import matplotlib.pyplot as plt
from datetime import timedelta
from datetime import datetime
import random

## Int values for Gesture codes.
NUMBER_GESTURES = 9
GESTURE_CODES = {
    'N': 0,
    'FT': 1,
    'ST': 2,
    'FS': 3,
    'FSA': 4,
    'VSS': 5,
    'BS': 6,
    'SS': 7,
    'C': 8}


#####################
#
# Full Transition Matrix Calculations.
#
#####################

def full_one_step_transition(e1, e2):
    """
    Calculates a full transition matrix between two states.
    """
    matrix = full_empty_transition_matrix()
    matrix[e2][e1] += 1 
    return matrix

def full_empty_transition_matrix():
    """
    Returns a full empty transition matrix.
    """
    return np.zeros([NUMBER_GESTURES,NUMBER_GESTURES]) # Full gesture matrix

def full_create_transition_dataframe(states):
    """
    Given a the gesture states of a single player, 
    calculates a dataframe of full one-step transition matrices.
    """
    dictionary_output = {}
    for col in states:
        matrices = [full_empty_transition_matrix()]
        prev = -1
        for index_loc in states[col].index:
            curr = index_loc
            if prev != -1:
                from_state = states.at[prev, col]
                to_state = states.at[curr, col]
                matrix = full_one_step_transition(from_state, to_state)
                matrices.append(matrix)
            prev = index_loc
            dictionary_output[col] = matrices
    return pd.DataFrame(index=states.index, data=dictionary_output)

def calculate_full_group_transition_matrix(states_frame):
    """
    Returns the group's transition matrix for a whole performance.
    """
    if not isinstance(states_frame, pd.DataFrame) or states_frame.empty:
        return None
    transitions = full_create_transition_dataframe(states_frame.dropna()).dropna()
    if transitions.empty:
        return None
    cols = [transitions[n] for n in transitions.columns]
    for c in range(len(cols)):
        if c == 0:
            group_transitions = cols[c]
        else:
            group_transitions = group_transitions + cols[c]
    group_transitions = group_transitions.dropna()
    group_matrix = transition_sum(group_transitions)
    return group_matrix

def transition_sum(tran_arr):
    """
    Sums an array of transition matrices. Used for resampling during
    performances as well as creating a whole-performance transition
    matrix.
    """
    out = np.sum(tran_arr,axis=0).tolist()
    return out

def transition_matrix_to_stochastic_matrix(trans_matrix):
    """
    Convert a transition matrix with entries >1 to a stochastic matrix
    where rows sum to 1. Rows with zero in all entries stay as zero!
    """
    try:
        result = map((lambda x: map((lambda n: 0 if n == 0 else n/sum(x)),x)), trans_matrix)
    except ZeroDivisionError:
        print("Fail! Zero division error when making stochastic matrix.")
        result = trans_matrix
    return result

def transition_matrix_to_normal_transition_matrix(trans_matrix):
    """
    Convert a transition matrix with entries > 1 to a normal
    transition matrix ( under the element-wise 1-norm i.e. ||M||_1 =
    1). Zero-matrices stay zero.
    """
    m = sum(sum(abs(np.array(trans_matrix))))
    if m > 0:
        result = trans_matrix / m
    else:
        result = trans_matrix
    return result

#####################
#
# Matrix Measures
#
#####################
	
def flux_measure(mat):
    """
    Measure of a transition matrix's flux. Given a numpy matrix M with
    diagonal D, returns the ||M||_1 - ||D||_1 / ||M||_1 Maximised at 1
    when nothing on diagonal, Minimised at 0 when everything on
    diagonal.
    """
    mat = np.array(mat)
    d = np.linalg.norm(mat.diagonal(),1) # |d|_1 
    m = sum(sum(abs(mat))) # |M|_1
    if m == 0:
        # Take care of case of empty matrix
        # returning 0 is wrong but more benign than NaN
        measure = 0
    else:
        measure = (m - d) / m # Flux.
    return measure

def entropy_measure(mat):
    """
    Measures a transition matrix's entropy in the information
    theoretic sense. H(P) = -\sum_{i,j}p_{ij}\log_2(p_{ij}) Uses
    scipy.stats.entropy
    """
    return entropy(np.reshape(mat,len(mat)**2), base=2)
