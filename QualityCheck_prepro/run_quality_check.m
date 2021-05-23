function run_quality_check(data_dir)
	motion_check = prepro_motionCheck(data_dir);
	outliers = [motion_check.outlier];
	sub_ids = {motion_check.subID};
	outlier_numbers = cellfun(@(subid) str2double(subid{1}(end-3:end)), {sub_ids{outliers}});
	outlier_numbers_string = join(arrayfun(@(n) num2str(n), outlier_numbers, 'UniformOutput', false), ', ');
	if nnz(outliers) > 0
		outlier_numbers_string = outlier_numbers_string{1};
		fprintf('found %d motion outliers - %s\n', nnz(outliers), outlier_numbers_string);
	else
		outlier_numbers_string = '';
		fprintf('found 0 motion outliers\n');
	end
	
	% write outliers to file
	f = fopen('../Dataset Analysis/COI_motion_outliers.txt', 'w');
	fprintf(f, '[%s]', outlier_numbers_string);
	fclose(f);
	
	
	cd ../Preprocessing/
	proportion_intersection = check_GLM_mask_alignment(data_dir);
	normalisation_outliers = proportion_intersection(:,2) < 0.7;
	if nnz(normalisation_outliers) > 0
		fprintf('Found %d outliers from normalisation mask: %s\n', nnz(normalisation_outliers), mat2str(proportion_intersection(normalisation_outliers,:)));
	end
	
	cd ../QualityCheck_prepro/