function run_prepro_pairs(dataset_dir, index)
	pairs = read_pairs_text_file('../Dataset Analysis/COI_perfectpair_pairs.txt');
	prepro_subject(dataset_dir, pairs(index), 1);