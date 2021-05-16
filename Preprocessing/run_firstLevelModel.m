function run_firstLevelModel(datasetDir, subID)
% run first level GLM with the Physio output regressors 

% info   
dataDir = fullfile(datasetDir, 'data', sprintf('sub-%04d',subID));
sub_data = get_patient_data(datasetDir, subID);
scan_properties = get_protocol_data(datasetDir, sub_data.protocol);
outdir = [dataDir filesep 'GLM_output'];
if ~exist(outdir, 'dir')
    mkdir(outdir);
end

% Check whether subfolders exist.
if ~exist(dataDir, 'dir')
    error('Could not find specified subject data folder');
end
struct_dir = fullfile(dataDir, 't1');
if ~exist(struct_dir, 'dir')
    error('Could not find t1/ subfolder');
end
func_dir = fullfile(dataDir, 'rsfmri');
if ~exist(func_dir, 'dir')
    error('Could not find rsfmri/ subfolder');
end
physio_dir = fullfile(dataDir, 'physio_output');

%-----------------------------------------------------------------------
% Job saved on 15-May-2021 19:28:48 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.stats.fmri_spec.dir = {outdir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = str2double(scan_properties.TR_s_);
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = str2double(scan_properties.NumberOfSlices);
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = (str2double(scan_properties.NumberOfSlices)/2);

% specify scans (new names!)
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = {fullfile(func_dir, 'smooth_norm_fmap_slicecorr_vol.nii')};

% specify condition 
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.name = 'resting_state';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.onset = str2double(scan_properties.Dummy)+1;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.duration = str2double(scan_properties.NumberOfVolumes);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.orth = 1;

% specify additional regressors 
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {fullfile(physio_dir, 'multiple_regressors.txt')};
%matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
matlabbatch{2}.spm.stats.fmri_est.spmmat = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

% save and run batch 
save(['firstLevelModel_batch'], 'matlabbatch')
spm_jobman('run', matlabbatch)

end
