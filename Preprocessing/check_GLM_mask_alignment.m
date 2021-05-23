function proportion_intersection = check_GLM_mask_alignment(data_dir, outliers)

if nargin < 2
	outliers = [];
end

subjects = dir([data_dir filesep 'sub-*']);
subject_ids = cellfun(@(n) str2double(n(end-3:end)), {subjects.name});
subjects = subjects(~ismember(subject_ids, outliers)); % remove outliers

masks = zeros(79,95,79,length(subjects));

for p=1:length(subjects)
	mask_vol = spm_read_vols(spm_vol(fullfile(data_dir, subjects(p).name, 'GLM_output', 'mask.nii')));
	masks(:,:,:,p) = mask_vol;
end

masksAND = all(masks == 1, 4);
masksOR = any(masks == 1, 4);

proportion_intersection = zeros(length(subjects),2);
for p=1:length(subjects)
	proportion_intersection(p,1) = str2double(subjects(p).name(end-3:end));
	proportion_intersection(p,2) = nnz(masks(:,:,:,p) .* masksAND) / nnz(masks(:,:,:,p));
end

% print proportion of intersection for each subject
printfig = figure('Name', 'Proportion intersection', 'visible', 'off');
plot(proportion_intersection(:,1), proportion_intersection(:,2), '.');
title('Proportion of GLM mask intersection for each subject');
xlabel('subject number')
print(printfig, '-dpng', '-noui', '-r100', fullfile(data_dir, 'proportion_intersection.png'));
close(printfig);

tpm_vol = spm_read_vols(spm_vol('pf_TPM.nii'));
atlas_vol = spm_read_vols(spm_vol('../Parcellation/combined_atlas.nii'));

vol = spm_vol(fullfile(data_dir, subjects(1).name, 'GLM_output', 'mask.nii'));
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