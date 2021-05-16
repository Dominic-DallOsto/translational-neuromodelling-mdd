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

%%

% in the mean time we run the normalisation and pushforward unwarping
realign_atlas_mask('Glasser_nonzero.nii','Glasser.nii');
realign_atlas_mask('subcortical_atlas_cortex.nii','subcortical_atlas.nii');

%% now we select which labels we want
glasser = spm_vol('pf_Glasser.nii');
subcortical = spm_vol('pf_subcortical_atlas.nii');

glasser_vols = spm_read_vols(glasser);
subcortical_vols = spm_read_vols(subcortical);

subcortical_labels_to_remove = [2,3,4,5,7,8,14,15,24,41,42,43,44,46,47,85];
% subcortical_labels_to_remove = [subcortical_labels_to_remove, 17, 53]; % hippocampus is in glasser
for i=1:length(subcortical_labels_to_remove)
	subcortical_vols(subcortical_vols == subcortical_labels_to_remove(i)) = 0;
end

order_of_subcortical_labels = [10,11,12,13,17,18,26,28,31,49,50,51,52,53,54,58,60,63,16];
subcortical_vols_copy = subcortical_vols;
for i=1:length(order_of_subcortical_labels)
	subcortical_vols(subcortical_vols_copy == order_of_subcortical_labels(i)) = i;
end

glasser_vols_L = glasser_vols(1:round(size(glasser_vols,1)/2),:,:);
glasser_vols_R = glasser_vols(round(1+size(glasser_vols,1)/2):end,:,:);
glasser_split_vol = [glasser_vols_L; glasser_vols_R+(glasser_vols_R~=0)*180];

crossover = (glasser_vols ~= 0) .* (subcortical_vols ~= 0);
fprintf('We have %d overlapping voxels :(\n', nnz(crossover));

combined = subcortical_vols;
combined(combined ~= 0) = combined(combined ~= 0) + 360;
combined(glasser_split_vol ~= 0) = glasser_split_vol(glasser_split_vol ~= 0);
combined_nii = subcortical;
combined_nii.fname = 'combined_atlas.nii';
spm_write_vol(combined_nii, combined);