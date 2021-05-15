%-----------------------------------------------------------------------
% Job saved on 15-May-2021 17:17:27 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.spatial.normalise.est.subj.vol = {'D:\Uni\UZH\Translational Neuromodelling\Project\Code\Parcellation\subcort_cortex.nii,1'};
matlabbatch{1}.spm.spatial.normalise.est.eoptions.biasreg = 0.0001;
matlabbatch{1}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
matlabbatch{1}.spm.spatial.normalise.est.eoptions.tpm = {'C:\Users\Dominic\spm12\tpm\TPM.nii'};
matlabbatch{1}.spm.spatial.normalise.est.eoptions.affreg = 'mni';
matlabbatch{1}.spm.spatial.normalise.est.eoptions.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.normalise.est.eoptions.fwhm = 0;
matlabbatch{1}.spm.spatial.normalise.est.eoptions.samp = 3;
matlabbatch{2}.spm.util.defs.comp{1}.comp{1}.def(1) = cfg_dep('Normalise: Estimate: Deformation (Subj 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','def'));
matlabbatch{2}.spm.util.defs.out{1}.push.fnames = {'D:\labels.nii'};
matlabbatch{2}.spm.util.defs.out{1}.push.weight = {''};
matlabbatch{2}.spm.util.defs.out{1}.push.savedir.savepwd = 1;
matlabbatch{2}.spm.util.defs.out{1}.push.fov.bbvox.bb = [NaN NaN NaN
                                                         NaN NaN NaN];
matlabbatch{2}.spm.util.defs.out{1}.push.fov.bbvox.vox = [2 2 2];
matlabbatch{2}.spm.util.defs.out{1}.push.preserve = 2;
matlabbatch{2}.spm.util.defs.out{1}.push.fwhm = [0 0 0];
matlabbatch{2}.spm.util.defs.out{1}.push.prefix = 'pf_';
