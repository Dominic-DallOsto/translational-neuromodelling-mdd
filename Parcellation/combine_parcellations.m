%% extract the whitematter / cortex from each atlas
subcort = spm_vol('subcortical_atlas.nii');
cort = spm_vol('Glasser.nii');

subcort_vols = spm_read_vols(subcort);
cort_vols = spm_read_vols(cort);

subcort_cortex_vols = (subcort_vols == 3) + (subcort_vols == 42);
subcort_cortex = subcort;
subcort_cortex.fname='subcortical_atlas_cortex.nii';
spm_write_vol(subcort_cortex, subcort_cortex_vols);

cort_nonzero_vols = (cort_vols ~= 0);
cort_nonzero = cort;
cort_nonzero.fname='Glasser_nonzero.nii';
spm_write_vol(cort_nonzero, cort_nonzero_vols);

% crop / reslice atlases to match preprocessed data
realign_atlas_mask('Glasser_nonzero.nii','Glasser.nii');
realign_atlas_mask('subcortical_atlas_cortex.nii','subcortical_atlas.nii');

%% select which labels we want
glasser = spm_vol('pf_Glasser.nii');
subcortical = spm_vol('pf_subcortical_atlas.nii');

glasser_vols = round(spm_read_vols(glasser));
subcortical_vols = round(spm_read_vols(subcortical));

subcortical_labels_to_remove = [2,3,4,5,7,8,14,15,24,30,41,42,43,44,46,47,62,77,85];
subcortical_labels_to_remove = [subcortical_labels_to_remove, 17, 53]; % hippocampus is in glasser - remove from Fischl
order_of_subcortical_labels = [10,11,12,13,18,26,28,31,49,50,51,52,54,58,60,63,16];

if length([subcortical_labels_to_remove,order_of_subcortical_labels]) ~= nnz(unique(subcortical_vols))
	unique_subcort_labels = unique(subcortical_vols);
	leftover_labels = unique_subcort_labels(~ismember(unique_subcort_labels, [subcortical_labels_to_remove,order_of_subcortical_labels]));
	error("Error: label(s) %s in the subcortical mask aren't accounted for", mat2str(nonzeros(leftover_labels)));
end

for i=1:length(subcortical_labels_to_remove)
	subcortical_vols(subcortical_vols == subcortical_labels_to_remove(i)) = 0;
end

subcortical_vols_copy = subcortical_vols;
for i=1:length(order_of_subcortical_labels)
	subcortical_vols(subcortical_vols_copy == order_of_subcortical_labels(i)) = i;
end

glasser_vols_L = glasser_vols(1:round(size(glasser_vols,1)/2),:,:);
glasser_vols_R = glasser_vols(round(1+size(glasser_vols,1)/2):end,:,:);
glasser_split_vol = [glasser_vols_L; glasser_vols_R+(glasser_vols_R~=0)*180];

crossover = (glasser_vols ~= 0) .* (subcortical_vols_copy ~= 0);
fprintf('We have %d overlapping voxels :(\n', nnz(crossover));
fprintf('Overlapping regions: %s (Glasser atlas) and %s (freesurfer subcortical)\n', mat2str(round(unique(glasser_vols(crossover == 1)))), mat2str(round(unique(subcortical_vols_copy(crossover == 1)))));

combined = subcortical_vols;
combined(combined ~= 0) = combined(combined ~= 0) + 360;
combined(glasser_split_vol ~= 0) = glasser_split_vol(glasser_split_vol ~= 0);

% remove NaNs from the mask
combined(isnan(combined)) = 0;

combined_nii = subcortical;
combined_nii.fname = 'combined_atlas.nii';
spm_write_vol(combined_nii, combined);

%% Make the PAG
% https://pubmed.ncbi.nlm.nih.gov/28032002/#&gid=article-figures&pid=figure-1-uid-0

PAGs = zeros(size(combined));
% DL-PAG [0,-32,-8.5] +/- 6,2,2
% [40.0 41.0 31.8] +/- [3,1,1]
% [37:43,40:42,31:33]
PAGs(37:43,40:42,31:33) = 1;
% VL-PAG [0,-27,-8] +/- 3,1,1
% [40.0 43.5 32] +/- [1.5,0.5,0.5]
% [38:42,43,32]
PAGs(38:42,43,32) = 2;

PAG_nii = combined_nii;
PAG_nii.fname = 'PAG.nii';
spm_write_vol(PAG_nii, PAGs);