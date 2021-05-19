function matlabbatch = realign_atlas_mask(file_to_register, file_to_realign)

% matlabbatch = realign_atlas_mask(dataDir, run)
% Performs / sets up a preprocessing pipeline.
%
% Inputs:
%       file_to_register:  File to normalise to the grey matter of the TPM to calculate the distortion map
%       file_to_realign:  File to apply the distortion map to.
%
% Outputs:
%       matlabbatch: batch containing information about analysis.


% Find out where the Tissue Probability Maps (TPMs) of SPM are located
% on your computer.

matlabbatch = {};

RESLICE = 1;

%--------------------------------------------------------------------------
% Relsice atlas to match preprocessed data
matlabbatch{RESLICE}.spm.util.defs.comp{1}.id.space = {fullfile(pwd, file_to_register)};
matlabbatch{RESLICE}.spm.util.defs.out{1}.push.fnames = {fullfile(pwd, file_to_register); fullfile(pwd, file_to_realign)};
matlabbatch{RESLICE}.spm.util.defs.out{1}.push.weight = {''};
matlabbatch{RESLICE}.spm.util.defs.out{1}.push.savedir.savepwd = 1;
matlabbatch{RESLICE}.spm.util.defs.out{1}.push.fov.bbvox.bb = [-78 -112 -70 ; 78 76 85]; % to match preprocessing
matlabbatch{RESLICE}.spm.util.defs.out{1}.push.fov.bbvox.vox = [2 2 2];
matlabbatch{RESLICE}.spm.util.defs.out{1}.push.preserve = 2; % for categorical data
matlabbatch{RESLICE}.spm.util.defs.out{1}.push.fwhm = [0 0 0];
matlabbatch{RESLICE}.spm.util.defs.out{1}.push.prefix = 'pf_';


spm_jobman('initcfg');
spm_jobman('run',matlabbatch);