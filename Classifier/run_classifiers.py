import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.linear_model import Lasso
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier
from typing import List,Tuple
from sklearn.metrics import accuracy_score, balanced_accuracy_score, f1_score

'''
ATTENTION: Format of the datasets that are iterated in the inner for-loop must 
be in the following format:
[[dataset1_name, dataset1_X_train, dataset1_X_test, dataset1_y_train, dataset1_y_test],
[dataset2_name, dataset2_X_train, dataset2_X_test, dataset2_y_train, dataset2_y_test],
[dataset3_name, dataset3_X_train, dataset3_X_test, dataset3_y_train, dataset3_y_test]]
'''

def run_classifiers(datasets: List[Tuple[str,np.ndarray,np.ndarray,np.ndarray,np.ndarray]]):
	# Used for keys of score dictionary
	names = ["Logistic Regression", "Lasso", "Random Forest"]
	# names = ["Logistic Regression", "Lasso", "Random Forest", "AdaBoost"]

	# A list of classifier objects, will be iterated over - lambda function so we newly initialise the classifier for each dataset
	classifiers = [
		lambda : LogisticRegression(random_state=1, max_iter=1000),
		lambda : LogisticRegression(penalty='l1', random_state=1, solver='liblinear', max_iter=1000),
		lambda : RandomForestClassifier(max_depth=5, n_estimators=10, max_features=1),
		# lambda : AdaBoostClassifier()
	]

	# Empty dictionary for the classifier scores,
	# key is a classifier, value is a dictionary of dataset : accuracy-score
	scores = {}

	# Iterate over each dataset
	for i, ds in enumerate(datasets):
		ds_name = ds[0]
		X_train = ds[1]
		X_test = ds[2]
		y_train = ds[3]
		y_test = ds[4]
		print(f"Processing dataset {ds_name}")

		dataset_scores = {}

		# Iterate over each classifier
		for i, classifier_function in enumerate(classifiers):
			classifier_name = names[i]
			print(f"... with {classifier_name} classifier")
			class_scores = {}
		
			# Train the classifier
			classifier = classifier_function()
			classifier.fit(X_train, y_train)

			# Predict on the training and test sets
			preds_train = classifier.predict(X_train)
			preds_test = classifier.predict(X_test)

			# Update scores dictionary
			dataset_scores.update({
				f'{classifier_name} Training Accuracy' : accuracy_score(y_train, preds_train),
				f'{classifier_name} Training Balanced Accuracy' : balanced_accuracy_score(y_train, preds_train),
				f'{classifier_name} Training F1 Score' : f1_score(y_train, preds_train),
				f'{classifier_name} Testing Accuracy' : accuracy_score(y_test, preds_test),
				f'{classifier_name} Testing Balanced Accuracy' : balanced_accuracy_score(y_test, preds_test),
				f'{classifier_name} Testing F1 Score' : f1_score(y_test, preds_test)
			}) 

		scores.update({ds_name : dataset_scores})

	return scores