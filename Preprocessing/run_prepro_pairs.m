function run_prepro_pairs(dataset_dir, index, steps_to_run)
	pairs = read_pairs_text_file('../Dataset Analysis/COI_perfect_pairs.txt');
	
	if nargin < 3
		steps_to_run = [];
	end
	
	subject = pairs(index);
	preprocessing_pipeline(dataset_dir, subject, steps_to_run);