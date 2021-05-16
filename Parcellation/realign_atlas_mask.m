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
tpm_dir = fullfile(fileparts(which('spm')), 'tpm');

matlabbatch = {};

NORMALISATION = 1;
UNDISTORT = 2;

%--------------------------------------------------------------------------
% Normalise white matter from mask
matlabbatch{NORMALISATION}.spm.spatial.normalise.est.subj.vol = {fullfile(pwd, file_to_register)};
matlabbatch{NORMALISATION}.spm.spatial.normalise.est.eoptions.biasreg = 0.0001;
matlabbatch{NORMALISATION}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
matlabbatch{NORMALISATION}.spm.spatial.normalise.est.eoptions.tpm = {fullfile(tpm_dir, 'TPM.nii,1')};
matlabbatch{NORMALISATION}.spm.spatial.normalise.est.eoptions.affreg = 'mni';
matlabbatch{NORMALISATION}.spm.spatial.normalise.est.eoptions.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{NORMALISATION}.spm.spatial.normalise.est.eoptions.fwhm = 0;
matlabbatch{NORMALISATION}.spm.spatial.normalise.est.eoptions.samp = 3;

%--------------------------------------------------------------------------
% Undistort image
matlabbatch{UNDISTORT}.spm.util.defs.comp{1}.comp{1}.def(1) = cfg_dep('Normalise: Estimate: Deformation (Subj 1)', substruct('.','val', '{}',{NORMALISATION}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','def'));
matlabbatch{UNDISTORT}.spm.util.defs.out{1}.push.fnames = {fullfile(pwd, file_to_realign)};
matlabbatch{UNDISTORT}.spm.util.defs.out{1}.push.weight = {''};
matlabbatch{UNDISTORT}.spm.util.defs.out{1}.push.savedir.savepwd = 1;
matlabbatch{UNDISTORT}.spm.util.defs.out{1}.push.fov.bbvox.bb = [NaN NaN NaN
                                                         NaN NaN NaN];
matlabbatch{UNDISTORT}.spm.util.defs.out{1}.push.fov.bbvox.vox = [2 2 2];
matlabbatch{UNDISTORT}.spm.util.defs.out{1}.push.preserve = 2; % for categorical data
matlabbatch{UNDISTORT}.spm.util.defs.out{1}.push.fwhm = [0 0 0];
matlabbatch{UNDISTORT}.spm.util.defs.out{1}.push.prefix = 'pf_';

spm_jobman('initcfg');
spm_jobman('run',matlabbatch);