# Feb. 9, 2016 
# Author AJ Rader
# This file is a place for some useful python utilities at State Farm
# please document your function(s)

import seaborn as sns
import matplotlib.pyplt as plt
import numpy as np
import pandas as pd
from sklearn import metrics


## Functions for assessment/plotting of scikit learn things

def find_max_score_value(y_true, y_pred, metric_name, showplot=False):
    """
    y_true : numpy array of true values (0,1)
    y_pred: values of prediction, can be floats/probabilities since they are mapped to ints
    metric_name -->> a sklearn metric name
        * so far I've tested this with metrics.f1_score, metrics.precision_score, metrics.accuracy_score,
                                       metrics.matthews_corrcoef

    A poor-man's grid search over the evaluation metrics to identify
    the best offset values (i.e. point where desired metric score is
    highest)
    """
    scores = []
    offsets = []
    # stage 1: Note if the metric is outside of [0,1] this will not work.
    for offset in np.arange(0,10)/float(10):
        score = metric_name(y_true,map(np.int,y_pred+offset))
        scores.append(score)
        offsets.append(offset)
    # find the max
    mxscore = max(scores)
    mx_idx = scores.index(mxscore)
    #now offset below and above
    if mx_idx == 0:
        for offset in np.arange(0,16)/float(100):
            offset+=0.0
            score = metric_name(y_true,map(np.int,y_pred+offset))
            scores.append(score)
            offsets.append(offset)
    elif mx_idx == 9:
        for offset in np.arange(0,21)/float(100):
            offset+=0.8
            score = metric_name(y_true,map(np.int,y_pred+offset))
            scores.append(score)
            offsets.append(offset)
    else:
        base_offset = offsets[mx_idx-1]
        for offset in np.arange(0,21)/float(100):
            offset+=base_offset
            score = metric_name(y_true,map(np.int,y_pred+offset))
            scores.append(score)
            offsets.append(offset)

    if showplot:
        plt.plot(offsets,scores,'d',color='indigo')
        plt.xlabel('offset value')
        plt.ylabel(metric_name)

    mxmxscore = max(scores)
    mxmx_idx = scores.index(mxmxscore)
    print mxmxscore, offsets[mxmx_idx]
    #if verbose:
    #    print "__________"
    #    print scores
    #return mcc_scores, mcc_offsets
    return offsets[mxmx_idx]

def plot_conf_matrix(y_true, y_pred, normed=True, heatmap_color ='Blues', **kwargs):

    ## check to make sure that y_pred is an array of integers if y_true is a bunch of integers
    true_int_check = all(isinstance(a,int) for a in y_true)
    pred_int_check = all(isinstance(a,int) for a in y_pred)
    if true_int_check and not pred_int_check: # convert the y_pred values to integers
        if isinstance(y_pred, pd.Series):
            y_pred = y_pred.astype(int)

    my_c = metrics.confusion_matrix(y_true, y_pred)

    print metrics.matthews_corrcoef(y_true, y_pred)
    if normed:
        cm_normalized = my_c.astype('float') / my_c.sum(axis=1)[:, np.newaxis]
        my_c = cm_normalized
        plt.title('Normalized RF Classifier Confusion Matrix')
    else:
        plt.title('Random Forest Classifier Confusion Matrix')

    sns.heatmap(my_c, annot=True,  fmt='',cmap=heatmap_color, **kwargs)
    plt.ylabel('True')
    plt.xlabel('Assigned')
    plt.show()

    return


## function to load into pandas from hdfs (by copying to local filespace)
def pandas_read_hdfs(infile,**kwargs):
    """
    Function to 'read' a file from hdfs into a pandas dataframe.
    Note this is just a hack. It copies the file to the current working 
    directory, loads it and then deletes it from the local filesystem.

    Parameters
    ----------
    infile : a file in HDFS -- include the full pathname
    
    :return: dataframe
"""
    # copy the infile to the cwd
    !hdfs dfs -get {infile} .
    # identify the local file name
    inname = infile[infile.rfind('/')+1:]
    
    df=pd.read_csv(inname,**kwargs)
    # clean up local filespace
    !rm {inname}
    return df 
    

### related to impala
