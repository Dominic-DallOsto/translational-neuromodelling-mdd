function run_quality_check(data_dir)
	motion_check = prepro_motionCheck(data_dir);
	outliers = [motion_check.outlier];
	if nnz(outliers) > 0
		sub_ids = {motion_check.subID};
		fprintf('found %d outliers in: %s\n', nnz(outliers), cell2mat(join(cellfun(@(subid) subid, {sub_ids{outliers}}), ', ')));
	end
	
	cd ../Preprocessing/
	proportion_intersection = check_GLM_mask_alignment(data_dir);
	normalisation_outliers = proportion_intersection(:,2) < 0.7;
	if nnz(normalisation_outliers) > 0
		fprintf('Found %d outliers from normalisation mask: %s\n', nnz(normalisation_outliers), mat2str(proportion_intersection(normalisation_outliers,:)));
	end