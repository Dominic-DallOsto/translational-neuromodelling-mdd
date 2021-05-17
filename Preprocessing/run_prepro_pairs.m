function run_prepro_pairs(dataset_dir, index)
	pairs = read_pairs_text_file('../Dataset Analysis/COI_perfectpair_pairs.txt');
	
	subject = pairs(index);
	subject_dir = fullfile(dataset_dir,'data',sprintf('sub-%04d',subject));
	patient_data = get_patient_data(datasetDir, subject);
	scan_properties = get_protocol_data(datasetDir, patient_data.protocol);
	
	% Preprocessing
	if ~exist(fullfile(subject_dir, 'rsfmri', 'smooth_norm_meanfmap_slicecorr_vol.nii'), 'file')
		fprintf('Running preprocessing for subject %d.', subject);
		prepro_subject(dataset_dir, subject, 1);
	end
	
	% Physio
	if ~exist(fullfile(subject_dir, 'physio_output'), 'dir')
		fprintf('Running physio for subject %d.', subject);
		create_physio_regressors(dataset_dir, subject);
	end
	
	% GLM
	if ~exist(fullfile(subject_dir, 'GLM_output'), 'dir')
		fprintf('Running GLM for subject %d.', subject);
		run_firstLevelModel_with_Res(dataset_dir, subject);
	end
	
	% Parcellation
	if ~exist(fullfile(subject_dir, 'GLM_output', 'extracted_timeseries.mat'), 'file')
		fprintf('Running parcellation for subject %d.', subject);
		cd ../Parcellation/
		parcellate_vols(dataset_dir, subject, 'combined_atlas.nii');
	end
	
	% rDCM (with bandpass filtering)
	if ~exist(fullfile(subject_dir, 'rDCM'), 'dir')
		fprintf('Running rDCM for subject %d.', subject);
		cd ../rDCM
		run_rDCM(dataset_dir, subject, str2double(scan_properties.TR_s_));
	end