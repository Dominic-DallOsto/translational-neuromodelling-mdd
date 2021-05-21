function run_quality_check(dataset_dir)
	motion_check = prepro_motionCheck(dataset_dir);
	outliers = [motion_check.outlier];
	if nnz(outliers) > 0
		sub_ids = {motion_check.subID};
		fprintf('found %d outliers in: %s\n', nnz(outliers), cell2mat(join(cellfun(@(subid) subid, {sub_ids{outliers}}), ', ')));
	end
	
