function run_prepro(dataset_dir, index, steps_to_run)
	subjects = read_array_text_file('../Dataset Analysis/COI_all.txt');
	
	if nargin < 3
		steps_to_run = [];
	end
	
	subject = subjects(index);
	subject_dir = fullfile(dataset_dir,'data',sprintf('sub-%04d',subject));
	patient_data = get_patient_data(dataset_dir, subject);
	scan_properties = get_protocol_data(dataset_dir, patient_data.protocol);
	
	% Preprocessing
	if any(find(steps_to_run == 1)) || ~exist(fullfile(subject_dir, 'rsfmri', 'smooth_norm_meanfmap_slicecorr_vol.nii'), 'file')
		fprintf('Running preprocessing for subject %d.', subject);
		prepro_subject(dataset_dir, subject, 1);
	end
	
	% Physio
	if any(find(steps_to_run == 2)) ||~exist(fullfile(subject_dir, 'physio_output'), 'dir')
		fprintf('Running physio for subject %d.', subject);
		create_physio_regressors(dataset_dir, subject);
	end
	
	% GLM
	if any(find(steps_to_run == 3)) ||~exist(fullfile(subject_dir, 'GLM_output'), 'dir')
		fprintf('Running GLM for subject %d.', subject);
		run_firstLevelModel_with_Res(dataset_dir, subject);
	end
	
	% Parcellation
	if any(find(steps_to_run == 4)) ||~exist(fullfile(subject_dir, 'GLM_output', 'extracted_timeseries.mat'), 'file')
		fprintf('Running parcellation for subject %d.', subject);
		cd ../Parcellation/
		parcellate_vols(dataset_dir, subject, 'combined_atlas.nii');
	end
	
	% rDCM (with bandpass filtering)
	if any(find(steps_to_run == 5)) ||~exist(fullfile(subject_dir, 'rDCM'), 'dir')
		fprintf('Running rDCM for subject %d.', subject);
		cd ../rDCM
		run_rDCM(dataset_dir, subject, str2double(scan_properties.TR_s_));
	end
	
	% just save the A matrix to reduce space
	if any(find(steps_to_run == 5)) || ~exist(fullfile(subject_dir, 'rDCM', 'dcm_A.mat'), 'file')
		data = load(fullfile(subject_dir, 'rDCM', 'dcm_output.mat'));
		A = data.output.Ep.A;
		save(fullfile(subject_dir, 'rDCM', 'dcm_A.mat'), 'A');
	end