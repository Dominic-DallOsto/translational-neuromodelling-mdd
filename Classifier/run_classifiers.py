import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.linear_model import Lasso
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier
from typing import List,Tuple
from sklearn.metrics import accuracy_score, balanced_accuracy_score, f1_score
from sklearn.model_selection import StratifiedKFold, KFold

'''
ATTENTION: Format of the datasets that are iterated in the inner for-loop must 
be in the following format:
[[dataset1_name, dataset1_X_train, dataset1_X_test, dataset1_y_train, dataset1_y_test],
[dataset2_name, dataset2_X_train, dataset2_X_test, dataset2_y_train, dataset2_y_test],
[dataset3_name, dataset3_X_train, dataset3_X_test, dataset3_y_train, dataset3_y_test]]
'''

def run_classifiers(datasets: List[Tuple[str,np.ndarray,np.ndarray,np.ndarray,np.ndarray]]):
	# Used for keys of score dictionary
	names = ["Lasso_cv"]
	# names = ["Logistic Regression", "Lasso", "Lasso_cv", "Random Forest"]
	# names = ["Logistic Regression", "Lasso", "Random Forest", "AdaBoost"]

	# A list of classifier objects, will be iterated over - lambda function so we newly initialise the classifier for each dataset
	classifiers = [
		# lambda : LogisticRegression(random_state=1, max_iter=1000),
		# lambda : LogisticRegression(penalty='l1', random_state=1, solver='liblinear', max_iter=1000),
		# lambda hyp: Lasso(alpha=hyp),
		lambda hyp: LogisticRegression(penalty='l1', C=1/hyp, random_state=1, solver='liblinear', max_iter=1000),
		# lambda : RandomForestClassifier(max_depth=5, n_estimators=10, max_features=1),
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

			if classifier_name.endswith('cv'):
				# Do the cross validation
				all_classifiers = []
				skf = StratifiedKFold(10, shuffle=True, random_state=1)

				# cross validation outer loop
				for train_index, validation_index in skf.split(X_train, y_train):
					X_cv_train = X_train[train_index]
					y_cv_train = y_train[train_index]
					X_cv_validation = X_train[validation_index]
					y_cv_validation = y_train[validation_index]

					print(f'X_CV [{X_cv_train.shape}], y_CV [{y_cv_train.shape}]')
					
					# take 10 subsamples
					mdd_patients = X_cv_train[y_cv_train == 1]
					mdd_labels = y_cv_train[y_cv_train == 1]
					healthy_controls = X_cv_train[y_cv_train == 0]
					healthy_controls_labels = y_cv_train[y_cv_train == 0]
					for ss in range(10):
						# randomly sample subset of healthy controls
						subsample_indices = np.random.choice(healthy_controls.shape[0], mdd_patients.shape[0])
						healthy_controls_subsample = healthy_controls[subsample_indices]
						healthy_controls_labels_subsample = healthy_controls_labels[subsample_indices]
						X_subset = np.vstack((mdd_patients,healthy_controls_subsample))
						y_subset = np.hstack((mdd_labels,healthy_controls_labels_subsample))

						# print(f'hc_ss [{healthy_controls_subsample.shape}], hc_ss [{healthy_controls_labels_subsample.shape}]')
						# print(f'mdd_ss [{mdd_patients.shape}], mdd_ss [{mdd_labels.shape}]')
						# print(f'X_ss [{X_subset.shape}], y_ss [{y_subset.shape}]')

						# kf = KFold(10, shuffle=True, random_state=1)
						kf = KFold(3, shuffle=True, random_state=1)

						# alphas = [1e-5,1e-4,1e-3,1e-2,1e-1,1,10]
						# alphas = [1e-5,1e-4,1e-3,1e-2,1e-1,1]
						alphas = [0.5,1.0]
						scores = []
						for alpha in alphas:
							# tune our alpha values
							alpha_scores = []
							for inner_train_index, inner_validation_index in kf.split(X_subset, y_subset):
								X_inner_train = X_subset[inner_train_index]
								y_inner_train = y_subset[inner_train_index]
								X_inner_validation = X_subset[inner_validation_index]
								y_inner_validation = y_subset[inner_validation_index]
								
								classifier = classifier_function(alpha)
								classifier.fit(X_inner_train, y_inner_train)
								score = classifier.score(X_inner_validation, y_inner_validation)
								# print(f'score = {score}, alpha = {alpha}')
								alpha_scores.append(score)
							scores.append(np.mean(np.array(alpha_scores)))
						best_alpha = alphas[np.argmax(np.array(scores))]
						print(f'alpha validation scores = {scores}, best alpha = {best_alpha}')

						# Now we have the best alpha we can train our classifier on this subsample
						classifier = classifier_function(best_alpha)
						classifier.fit(X_subset, y_subset)
						# Save this (one of the 100) classifiers
						all_classifiers.append(classifier)

				# Now run the 100 classifiers, and average the results
				predictions_train = np.mean(np.vstack([classifier.predict(X_train) for classifier in classifiers]), axis=0) > 0.5
				predictions_test = np.mean(np.vstack([classifier.predict(X_test) for classifier in classifiers]), axis=0) > 0.5

			else:
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