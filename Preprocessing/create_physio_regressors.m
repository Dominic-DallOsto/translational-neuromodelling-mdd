
function create_physio_regressors(datasetDir, subID)
%% 
% function creates data-driven physiological noise and motion regressors
% using the PhysIO toolbox from tapas
% 
% Inputs: 
%       datasetDir:   Path to subject data
%       subID:        Patient number (int)
% 
% Output:
%       creates a physio_output folder in the subjects 

%%
% info   
dataDir = fullfile(datasetDir, 'data', sprintf('sub-%04d',subID));
sub_data = get_patient_data(datasetDir, subID);
scan_properties = get_protocol_data(datasetDir, sub_data.protocol);
outdir = [dataDir filesep 'physio_output'];

% Check whether subfolders exist.
if ~exist(outdir, 'dir')
    mkdir(outdir);
end
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

%% matlabbatch 
%-----------------------------------------------------------------------
% Job saved on 15-May-2021 16:29:49 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.tools.physio.save_dir = {outdir};

% params for physio noise model (not used)
matlabbatch{1}.spm.tools.physio.log_files.vendor = 'Philips';
matlabbatch{1}.spm.tools.physio.log_files.cardiac = {''};
matlabbatch{1}.spm.tools.physio.log_files.respiration = {''};
matlabbatch{1}.spm.tools.physio.log_files.sampling_interval = [];
matlabbatch{1}.spm.tools.physio.log_files.relative_start_acquisition = 0;
matlabbatch{1}.spm.tools.physio.log_files.align_scan = 'last';
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nslices = str2double(scan_properties.NumberOfSlices);
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.NslicesPerBeat = [];
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.TR = str2double(scan_properties.TR_s_);
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Ndummies = 0;
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nscans = str2double(scan_properties.NumberOfVolumes);
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.onset_slice = 0;
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.time_slice_to_slice = [];
matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nprep = [];
matlabbatch{1}.spm.tools.physio.scan_timing.sync.nominal = struct([]);
matlabbatch{1}.spm.tools.physio.preproc.cardiac.modality = 'ECG';
matlabbatch{1}.spm.tools.physio.preproc.cardiac.filter.no = struct([]);
matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.min = 0.4;
matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.file = 'initial_cpulse_kRpeakfile.mat';
matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.max_heart_rate_bpm = 90;
matlabbatch{1}.spm.tools.physio.preproc.cardiac.posthoc_cpulse_select.off = struct([]);

% physio model motion regressors & nois rois
matlabbatch{1}.spm.tools.physio.model.output_multiple_regressors = 'multiple_regressors.txt';
matlabbatch{1}.spm.tools.physio.model.output_physio = 'physio.mat';
matlabbatch{1}.spm.tools.physio.model.orthogonalise = 'none';
matlabbatch{1}.spm.tools.physio.model.censor_unreliable_recording_intervals = false;
matlabbatch{1}.spm.tools.physio.model.retroicor.no = struct([]);
matlabbatch{1}.spm.tools.physio.model.rvt.no = struct([]);
matlabbatch{1}.spm.tools.physio.model.hrv.no = struct([]);
matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.fmri_files = {fullfile(func_dir, 'smooth_norm_fmap_slicecorr_vol.nii')}; 
matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.roi_files = {fullfile(struct_dir, 'c2defaced_mprage.nii')};                         
matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.force_coregister = 'Yes';
matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.thresholds = 0.9;
matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.n_voxel_crop = 0;
matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.n_components = 1;
matlabbatch{1}.spm.tools.physio.model.movement.yes.file_realignment_parameters = {fullfile(func_dir, 'rp_slicecorr_vol.txt')};    
matlabbatch{1}.spm.tools.physio.model.movement.yes.order = 6;
matlabbatch{1}.spm.tools.physio.model.movement.yes.censoring_method = 'FD';
matlabbatch{1}.spm.tools.physio.model.movement.yes.censoring_threshold = 0.5;
matlabbatch{1}.spm.tools.physio.model.other.no = struct([]);

% additional params - level must be 1 otherwise it does not run 
matlabbatch{1}.spm.tools.physio.verbose.level = 1;
matlabbatch{1}.spm.tools.physio.verbose.fig_output_file = 'physio_verbose';
matlabbatch{1}.spm.tools.physio.verbose.use_tabs = false;

% save and run batch 
save([outdir filesep 'create_physio_batch'], 'matlabbatch')
spm_jobman('run', matlabbatch)

end
