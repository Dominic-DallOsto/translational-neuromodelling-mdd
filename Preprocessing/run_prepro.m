function run_prepro(dataset_dir, subjects_file, index, steps_to_run)
	subjects = read_array_text_file(subjects_file);
	
	if nargin < 3
		steps_to_run = [];
	end
	
	subject = subjects(index);
	preprocessing_pipeline(dataset_dir, subject, steps_to_run);