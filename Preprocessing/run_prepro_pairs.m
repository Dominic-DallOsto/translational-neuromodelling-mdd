function run_prepro_pairs(dataset_dir, pairs_file, index, steps_to_run)
	pairs = read_pairs_text_file(pairs_file);
	
	if nargin < 4
		steps_to_run = [];
	end
	
	subject = pairs(index);
	preprocessing_pipeline(dataset_dir, subject, steps_to_run);
