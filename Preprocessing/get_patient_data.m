function data = get_patient_data(data_directory, N)
	t = readtable(fullfile(data_directory,'participants.tsv'),'FileType','text');
	data = t(N,:);