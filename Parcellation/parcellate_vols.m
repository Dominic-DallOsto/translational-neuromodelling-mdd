function parcellate_vols(datasetDir, subID, atlasFile)
% function extracts the timeseries from multiple ROIs defined in a label
% atlas 
%
% Inputs
%   datasetDir: path to folder of subjects
%   subID:      int 
%   atlasFile:  File containing all ROI with different labels (.nii)

dataDir = fullfile(datasetDir, 'data', sprintf('sub-%04d', subID)); 
glm_dir = fullfile(dataDir, 'GLM_output'); %Specify path to SPM file (GLM output)

atlas = spm_vol(atlasFile);
data = spm_vol(fullfile(dataDir,'rsfmri','smooth_norm_fmap_slicecorr_vol.nii'));

atlas_vol = spm_read_vols(atlas);
data_vols = spm_read_vols(data);

nlabels = nnz(unique(atlas_vol));
nvols = size(data_vols, 4);

timeseries = zeros(nvols,nlabels);

for label = 1:nlabels
	% take the mean of the volume corresponding to the label, for each volume in the timeseries
	timeseries(:,label) = nanmean(reshape(data_vols(repmat(atlas_vol == label, 1,1,1,nvols)), [], nvols), 1);
end

save(fullfile(glm_dir, 'extraced_timeseries.mat'), 'timeseries');