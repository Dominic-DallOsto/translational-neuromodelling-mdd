function preprocessing_pipeline(dataset_dir, subject, steps_to_run)

	subject_dir = fullfile(dataset_dir,'data',sprintf('sub-%04d',subject));
	patient_data = get_patient_data(dataset_dir, subject);
	scan_properties = get_protocol_data(dataset_dir, patient_data.protocol);
	
	% Preprocessing
	if any(find(steps_to_run == 1)) || (isempty(steps_to_run) && ~exist(fullfile(subject_dir, 'rsfmri', 'smooth_norm_meanfmap_slicecorr_vol.nii'), 'file'))
		fprintf('Running preprocessing for subject %d.\n', subject);
		prepro_subject(dataset_dir, subject, 1);
	end
	
	% Physio
	if any(find(steps_to_run == 2)) || (isempty(steps_to_run) && ~exist(fullfile(subject_dir, 'physio_output'), 'dir'))
		fprintf('Running physio for subject %d.\n', subject);
		create_physio_regressors(dataset_dir, subject);
	end
	
	% GLM
	if any(find(steps_to_run == 3)) || (isempty(steps_to_run) && ~exist(fullfile(subject_dir, 'GLM_output'), 'dir'))
		fprintf('Running GLM for subject %d.\n', subject);
		run_firstLevelModel_with_Res(dataset_dir, subject);
	end
	
	% Parcellation
	if any(find(steps_to_run == 4)) || (isempty(steps_to_run) && ~exist(fullfile(subject_dir, 'GLM_output', 'extracted_timeseries.mat'), 'file'))
		fprintf('Running parcellation for subject %d.\n', subject);
		cd ../Parcellation/
		parcellate_vols(dataset_dir, subject, 'combined_atlas.nii');
	end
	
	% rDCM
	if any(find(steps_to_run == 5)) || (isempty(steps_to_run) && ~exist(fullfile(subject_dir, 'rDCM'), 'dir'))
		fprintf('Running rDCM for subject %d.\n', subject);
		cd ../rDCM
		run_rDCM(dataset_dir, subject, str2double(scan_properties.TR_s_));
	end
	
	% reorder A matrix and save it separately to reduce space
	if any(find(steps_to_run == 6)) || (isempty(steps_to_run) && ~exist(fullfile(subject_dir, 'rDCM', 'dcm_A.mat'), 'file'))
		fprintf('Reordering and saving rDCM A matrix for subject %d.\n', subject);
		data = load(fullfile(subject_dir, 'rDCM', 'dcm_output.mat'));
		A = data.output.Ep.A;
		cd ../Parcellation/
		A = reorder_A_matrix(A);
		save(fullfile(subject_dir, 'rDCM', 'dcm_A.mat'), 'A');
	end

	% get correlation values for each pair of timeseries
	if any(find(steps_to_run == 7)) || (isempty(steps_to_run) && ~exist(fullfile(subject_dir, 'correlation', 'correlation_components.mat'), 'file'))
		fprintf('Saving correlation coefficient matrix lower diagonal for subject %d.\n', subject);
		cd ../rDCM
		timeseries_correlation(dataset_dir, subject);
	end