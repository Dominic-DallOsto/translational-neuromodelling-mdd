# Need to run this before analysing the dataset, otherwise SPM can't read the files
import os

if __name__ == "__main__":
	dataset_location = 'SRPBS_OPEN' # made a hard link to the dataset here
	subject_data_dir = f'{dataset_location}/data'

	subjects = os.listdir(subject_data_dir)

	for subject in subjects:
		subject_dir = f'{subject_data_dir}/{subject}/rsfmri'
		for file in os.listdir(subject_dir):
			if file.startswith('vol_') and not file.endswith('.nii'):
				os.rename(f'{subject_dir}/{file}',f'{subject_dir}/{file}.nii')