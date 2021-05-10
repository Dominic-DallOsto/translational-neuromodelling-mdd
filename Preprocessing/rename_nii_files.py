# Need to run this before analysing the dataset, otherwise SPM can't read the files
import os
import sys

if __name__ == "__main__":
	if len(sys.argv) <= 1:
		print('Please provide the location of the dataset directory by running the script like `python nename_nii_files.py ./SRPBS_OPEN`')
	else:
		dataset_location = sys.argv[1]
		subject_data_dir = f'{dataset_location}/data'
		print(f'Reading subject data from {subject_data_dir}.')

		subjects = os.listdir(subject_data_dir)

		for subject in subjects:
			subject_dir = f'{subject_data_dir}/{subject}/rsfmri'
			for file in os.listdir(subject_dir):
				if file.startswith('vol_') and not file.endswith('.nii'):
					os.rename(f'{subject_dir}/{file}',f'{subject_dir}/{file}.nii')