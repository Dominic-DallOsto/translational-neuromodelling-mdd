function timeseries_correlation(datasetDir, subID)

dataDir = fullfile(datasetDir, 'data', sprintf('sub-%04d',subID));
data = load(fullfile(dataDir, 'GLM_output', 'extracted_timeseries.mat'));

corr_mat = corrcoef(data.timeseries);

% reorder labels
cd ../Parcellation
corr_mat = reorder_A_matrix(corr_mat);
cd ../rDCM

lower_diag_indices = tril(true(size(corr_mat)), -1);
corr_components = corr_mat(lower_diag_indices);

correlation_dir = fullfile(dataDir, 'correlation');
if ~exist(correlation_dir, 'dir')
	mkdir(correlation_dir)
end

save(fullfile(correlation_dir, 'correlation_components.mat'), 'corr_components');