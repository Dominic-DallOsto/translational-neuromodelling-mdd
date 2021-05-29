# -*- coding: utf-8 -*-
"""The Mother of All Scripts.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/1_YH60zmDqwroOWaqjqr_2WUdSu3lDrdf
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.linear_model import Lasso
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier

def score(y_pred, y_true):
  error = np.square(np.log10(y_pred +1) - np.log10(y_true +1)).mean() ** 0.5
  score = 1 - error
  return score

'''
ATTENTION: Format of the datasets that are iterated in the inner for-loop must 
be in the following format:
[[dataset1_name, dataset1_X_train, dataset1_X_test, dataset1_y_train, dataset1_y_test],
[dataset2_name, dataset2_X_train, dataset2_X_test, dataset2_y_train, dataset2_y_test],
[dataset3_name, dataset3_X_train, dataset3_X_test, dataset3_y_train, dataset3_y_test]]
'''

# Used for keys of score dictionary
names = ["Logistic Regression", "Lasso", "Random Forest", "AdaBoost"]

# A list of classifier objects, will be iterated over
classifiers = [
    LogisticRegression(random_state=1),
    Lasso(0.1, fit_intercept=False, max_iter=1000),           
    RandomForestClassifier(max_depth=5, n_estimators=10, max_features=1),
    AdaBoostClassifier(),
    ]

# Empty dictionary for the classifier scores,
# key is a classifier, value is a dictionary of dataset : accuracy-score
scores = {}

# Iterate over each classifier
for i, classifier in enumerate(classifiers):
  classifier_name = names[i]
  print(f"Processing {classifier_name} classifier...")
  class_scores = {}
  
  # Iterate over each dataset
  for i, ds in enumerate(datasets):
    ds_name = ds[0]
    print(f"... for {ds_name} classifier")
    X_train = ds[1]
    X_test = ds[2]
    y_train = ds[3]
    y_test = ds[4]

    # Train the classifier
    classifier.fit(X_train, y_train)

    # Predict the test set
    preds = classifier.predict(X_test)

    # Score the predictions
    acc = score(preds, y_test)

    # Update scores dictionary
    class_scores.update( {ds_name : acc} ) 

  scores.update( { classifier_name : class_scores } )