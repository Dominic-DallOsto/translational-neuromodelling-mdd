pairs = read_pairs_text_file('../Dataset Analysis/COI_perfectpair_pairs.txt');
data_dir = '../SRPBS_OPEN/data';

pairs = [1,491];

masks = zeros(79,95,79,length(pairs));

for p=1:length(pairs)
	mask_vol = spm_read_vols(spm_vol(fullfile(data_dir, sprintf('sub-%04d',pairs(p)), 'GLM_output', 'mask.nii')));
	masks(:,:,:,p) = mask_vol;
end

masksAND = all(masks == 1, 4);
masksOR = any(masks == 1, 4);

proportion_intersection = zeros(length(pairs),2);
for p=1:length(pairs)
	proportion_intersection(p,1) = pairs(p);
	proportion_intersection(p,2) = nnz(masks(:,:,:,p) .* masksAND) / nnz(masks(:,:,:,p));
end

tpm_vol = spm_read_vols(spm_vol('pf_TPM.nii'));
atlas_vol = spm_read_vols(spm_vol('../Parcellation/combined_atlas.nii'));

vol = spm_vol(fullfile(data_dir, sprintf('sub-%04d',pairs(1)), 'GLM_output', 'mask.nii'));
vol.fname = fullfile(data_dir, 'maskAND.nii');
spm_write_vol(vol, masksAND);
vol.fname = fullfile(data_dir, 'maskOR.nii');
spm_write_vol(vol, masksOR);
vol.fname = fullfile(data_dir, 'maskAND_missing.nii');
spm_write_vol(vol, tpm_vol(:,:,:,1) .* ~masksAND);
vol.fname = fullfile(data_dir, 'maskOR_missing.nii');
spm_write_vol(vol, tpm_vol(:,:,:,1) .* ~masksOR);
vol.fname = fullfile(data_dir, 'maskAND_missing_atlased.nii');
spm_write_vol(vol, atlas_vol .*(tpm_vol(:,:,:,1) .* ~masksAND));

save(fullfile(data_dir, 'proportion_intersection.mat'), 'proportion_intersection');