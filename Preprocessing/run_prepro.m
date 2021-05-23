function run_prepro(dataset_dir, index, steps_to_run)
	subjects = read_array_text_file('../Dataset Analysis/COI_all.txt');
	
	if nargin < 3
		steps_to_run = [];
	end
	
	subject = subjects(index);
	preprocessing_pipeline(dataset_dir, subject, steps_to_run);