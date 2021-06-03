import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.linear_model import Lasso
from sklearn.svm import SVC
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

def run_classifiers(datasets: List[Tuple[str,np.ndarray,np.ndarray,np.ndarray,np.ndarray]], num_outer=10, num_inner=10):
	# Used for keys of score dictionary
	names = ["RandomForest_cv"]
	#names = ["Lasso_cv", "SVM_cv", "RandomForest_cv"]
	# names = ["Logistic Regression", "Lasso", "Lasso_cv", "Random Forest"]
	# names = ["Logistic Regression", "Lasso", "Random Forest", "AdaBoost"]

	# A list of classifier objects, will be iterated over - lambda function so we newly initialise the classifier for each dataset
	classifiers = [
		# lambda : LogisticRegression(random_state=1, max_iter=1000),
		# lambda : LogisticRegression(penalty='l1', random_state=1, solver='liblinear', max_iter=1000),
		# lambda hyp: Lasso(alpha=hyp),
		#lambda hyp: LogisticRegression(penalty='l1', C=1/hyp, random_state=1, solver='liblinear', max_iter=1000),
		#lambda hyp : SVC(kernel='rbf', C=1/hyp),
		lambda hyp : RandomForestClassifier(max_depth=hyp),
		#lambda : RandomForestClassifier(max_depth=5, n_estimators=500),
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

			if classifier_name.endswith('cv'):
				# Do the cross validation
				all_classifiers = []
				test_accs = []
				test_balanced_accs = []
				test_f1_scores = []
				test_probs = []
				skf = StratifiedKFold(num_outer, shuffle=True, random_state=1)

				# cross validation outer loop
				for outer, (train_index, validation_index) in enumerate(skf.split(X_train, y_train)):
					X_cv_train = X_train[train_index]
					y_cv_train = y_train[train_index]
					X_cv_validation = X_train[validation_index]
					y_cv_validation = y_train[validation_index]

					print(f'Running outer loop {outer}')
					# print(f'X_CV [{X_cv_train.shape}], y_CV [{y_cv_train.shape}]')
					
					# take 10 subsamples
					mdd_patients = X_cv_train[y_cv_train == 1]
					mdd_labels = y_cv_train[y_cv_train == 1]
					healthy_controls = X_cv_train[y_cv_train == 0]
					healthy_controls_labels = y_cv_train[y_cv_train == 0]
					for ss in range(num_inner):
						# randomly sample subset of healthy controls
						subsample_indices = np.random.choice(healthy_controls.shape[0], mdd_patients.shape[0])
						healthy_controls_subsample = healthy_controls[subsample_indices]
						healthy_controls_labels_subsample = healthy_controls_labels[subsample_indices]
						X_subset = np.vstack((mdd_patients,healthy_controls_subsample))
						y_subset = np.hstack((mdd_labels,healthy_controls_labels_subsample))

						print(f'Running subsample {outer*10+ss}')
						# print(f'hc_ss [{healthy_controls_subsample.shape}], hc_ss [{healthy_controls_labels_subsample.shape}]')
						# print(f'mdd_ss [{mdd_patients.shape}], mdd_ss [{mdd_labels.shape}]')
						# print(f'X_ss [{X_subset.shape}], y_ss [{y_subset.shape}]')

						# kf = KFold(10, shuffle=True, random_state=1)
						kf = KFold(10, shuffle=True, random_state=1)

						# alphas = [1e-5,1e-4,1e-3,1e-2,1e-1,1,10]
						# alphas = [1e-5,1e-4,1e-3,1e-2,1e-1,1]
						
						if classifier_name == "SVM_cv" or classifier_name == "Lasso_cv":
							alphas = [0.001,0.01,0.1,1.0]
						if classifier_name == "RandomForest_cv":
							alphas = [2, 3, 4, 5]
						alpha_mean_scores = []
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
							alpha_mean_scores.append(np.mean(np.array(alpha_scores)))
						best_alpha = alphas[np.argmax(np.array(alpha_mean_scores))]
						print(f'alpha validation scores = {alpha_mean_scores}, best alpha = {best_alpha}')
						
						# Now we have the best alpha we can train our classifier on this subsample
						classifier = classifier_function(best_alpha)
						classifier.fit(X_subset, y_subset)
						preds_prob = np.array(classifier.predict_proba(X_test))[:,1]
						preds_binary = preds_prob > 0.5
						acc_score = accuracy_score(preds_binary, y_test)
						balanced_score = balanced_accuracy_score(preds_binary, y_test)
						score_f1 = f1_score(preds_binary, y_test)
						# Save results of (one of the 100) classifiers
						#print('Acc_Score: ', acc_score)
						#print('Balanced_Score: ', balanced_score)
						#print('F1_Score: ', score_f1)
						all_classifiers.append(classifier)
						test_accs.append(acc_score)
						test_balanced_accs.append(balanced_score)
						test_f1_scores.append(score_f1)
						test_probs.append(preds_prob)

				# Now run the 100 classifiers, and average the results
				#print(f'prediction train = {np.mean(np.vstack([classifier.predict(X_train) for classifier in all_classifiers]), axis=0)}')
				#print(f'prediction test = {np.mean(np.vstack([classifier.predict(X_test) for classifier in all_classifiers]), axis=0)}')
				preds_train = np.mean(np.vstack([classifier.predict(X_train) for classifier in all_classifiers]), axis=0) > 0.5
				preds_test = np.mean(np.vstack(test_probs), axis=0) > 0.5

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
				f'{classifier_name} Testing F1 Score' : f1_score(y_test, preds_test),
				f'{classifier_name} All Testing Accs' : test_accs,
				f'{classifier_name} All Testing Balanced Accs' : test_balanced_accs,
				f'{classifier_name} All Testing F1 Scores' : test_f1_scores,
				f'{classifier_name} All Probabilities' : test_probs
			}) 

		scores.update({ds_name : dataset_scores})

	return scores