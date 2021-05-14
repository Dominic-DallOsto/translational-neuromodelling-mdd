function matlabbatch = prepro_subject(datasetDir, subject, run)

% matlabbatch = teach_prepro_subject(dataDir, run)
% Performs / sets up a preprocessing pipeline.
%
% Inputs:
%       dataDir:  Path to subject data folder (must contain structural/ and
%                 functional/ subfolders)
%       subject:  Patient number (int)
%       run:      if 0 -> just create struct [default]
%                 if 1 -> run directly
%                 if 2 -> run interactively (open Batch editor with analysis)
%
% Outputs:
%       matlabbatch: batch containing information about analysis.
%
% Created: Oct 2018, Jakob Heinzle, Translational Neuromodeling Unit, IBT
% University and ETH Zurich

if nargin < 3
    run = 0;
end

dataDir = fullfile(datasetDir,'data',sprintf('sub-%04d',subject));
patient_data = get_patient_data(datasetDir, subject);
scan_properties = get_protocol_data(datasetDir, patient_data.protocol);

% Check whether data folder exists.
if ~exist(dataDir, 'dir')
    error('Could not find specified data folder');
end
% Check whether subfolders exist.
struct_dir = fullfile(dataDir, 't1');
if ~exist(struct_dir, 'dir')
    error('Could not find t1/ subfolder');
end
func_dir = fullfile(dataDir, 'rsfmri');
if ~exist(func_dir, 'dir')
    error('Could not find rsfmri/ subfolder');
end
fmap_dir = fullfile(dataDir, 'fmap');
if ~exist(fmap_dir, 'dir')
    error('Could not find fmap/ subfolder');
end

% Find out where the Tissue Probability Maps (TPMs) of SPM are located
% on your computer.
tpm_dir = fullfile(fileparts(which('spm')), 'tpm');
spm_fmap_dir = fullfile(fileparts(which('spm')), 'toolbox', 'FieldMap');

matlabbatch = {};

CONVERT_3D_4D = 1;
SLICE_TIMING = 2;
REALIGN = 3;
GET_FIELD_MAP = 4;
APPLY_FIELD_MAP = 5;
NORMALISATION = 6;
COREGISTRATION = 7;
WRITE_FUNCTIONAL = 8;
SMOOTHING = 9;
WRITE_STRUCTURAL = 10;

scans = spm_select('FPList',func_dir,'^vol_.+');


%--------------------------------------------------------------------------
% Convert individual scans to a single 4D file (just a bit nicer)

matlabbatch{CONVERT_3D_4D}.spm.util.cat.vols = cellstr(scans);
matlabbatch{CONVERT_3D_4D}.spm.util.cat.name = 'vol.nii';
matlabbatch{CONVERT_3D_4D}.spm.util.cat.dtype = 0;
matlabbatch{CONVERT_3D_4D}.spm.util.cat.RT = str2double(scan_properties.TR_s_);

%--------------------------------------------------------------------------
% Slice timing correction
matlabbatch{SLICE_TIMING}.spm.temporal.st.scans{1}(1) = cfg_dep('3D to 4D File Conversion: Concatenated 4D Volume', substruct('.','val', '{}',{CONVERT_3D_4D}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','mergedfile'));
numberSlices = str2double(scan_properties.NumberOfSlices);
if isnan(numberSlices)
	throw(MLException('DataPreProcessing:GetNumberSlices',sprintf('Slice Number %s not recognised.',scan_properties.NumberOfSlices)))
else
	matlabbatch{SLICE_TIMING}.spm.temporal.st.nslices = numberSlices;
end
matlabbatch{SLICE_TIMING}.spm.temporal.st.tr = str2double(scan_properties.TR_s_);
matlabbatch{SLICE_TIMING}.spm.temporal.st.ta = matlabbatch{SLICE_TIMING}.spm.temporal.st.tr * (1 - 1/numberSlices);
if strcmp(strip(scan_properties.SliceAcquisitionOrder), 'Ascending')
	matlabbatch{SLICE_TIMING}.spm.temporal.st.so = (1:1:numberSlices);
elseif strcmp(strip(scan_properties.SliceAcquisitionOrder), 'Ascending (Interleaved )') || ...
		strcmp(strip(scan_properties.SliceAcquisitionOrder), 'Ascending (interleave)') % there's a typo in one...
	matlabbatch{SLICE_TIMING}.spm.temporal.st.so = [1:2:numberSlices, 2:2:numberSlices];
else
	throw(MLException('DataPreProcessing:GetSliceAcquisitionOrder',sprintf('Slice Acquisition Order %s not recognised.',scan_properties.SliceAcquisitionOrder)))
end
matlabbatch{SLICE_TIMING}.spm.temporal.st.refslice = numberSlices/2; % we normally use the middle slice as the reference
matlabbatch{SLICE_TIMING}.spm.temporal.st.prefix = 'slicecorr_';

%--------------------------------------------------------------------------
% Realign: motion correction and align two fMRI runs
matlabbatch{REALIGN}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{SLICE_TIMING}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{REALIGN}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{REALIGN}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{REALIGN}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{REALIGN}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{REALIGN}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{REALIGN}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{REALIGN}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{REALIGN}.spm.spatial.realign.estwrite.roptions.which = [0 1];
matlabbatch{REALIGN}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{REALIGN}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{REALIGN}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{REALIGN}.spm.spatial.realign.estwrite.roptions.prefix = 'realign_';

%--------------------------------------------------------------------------
% Field map correction: calculate voxel displacement map
if exist(fullfile(fmap_dir, 'phase.nii'),'file') == 2
	field_map_phase = fullfile(fmap_dir, 'phase.nii');
	field_map_magn = fullfile(fmap_dir, 'data_0000.nii');
elseif exist(fullfile(fmap_dir, 'fieldmap212APs006a2001.nii'),'file') == 2
	field_map_phase = fullfile(fmap_dir, 'fieldmap212APs006a2001.nii');
	field_map_magn = fullfile(fmap_dir, 'fieldmap212APs005a1001_1.nii');
elseif exist(fullfile(fmap_dir, 'fieldmap212PAs006a2001.nii'),'file') == 2
	field_map_phase = fullfile(fmap_dir, 'fieldmap212PAs006a2001.nii');
	field_map_magn = fullfile(fmap_dir, 'fieldmap212PAs005a1001_1.nii');
end
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.phase = {field_map_phase};
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.data.presubphasemag.magnitude = {field_map_magn};
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.et = [4.92 7.38]; % got these from the protocol pdf
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.maskbrain = 0; % don't mask the brain?
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.blipdir = -1; % left this at default
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.tert = 21.1; % left this at default
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.epifm = 0;
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.ajm = 0;
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.method = 'Mark3D';
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.fwhm = 10;
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.pad = 0;
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.uflags.ws = 1;
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.template = {fullfile(spm_fmap_dir, 'T1.nii')};
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.fwhm = 5;
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.nerode = 2;
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.ndilate = 4;
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.thresh = 0.5;
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.defaults.defaultsval.mflags.reg = 0.02;
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.session.epi = cellstr(scans(1,:)); % need to put something here or it throws an error
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.matchvdm = 0;
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.sessname = 'session';
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.writeunwarped = 0;
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.anat = '';
matlabbatch{GET_FIELD_MAP}.spm.tools.fieldmap.calculatevdm.subj.matchanat = 0;

%--------------------------------------------------------------------------
% Field map correction: unwarp functional images
matlabbatch{APPLY_FIELD_MAP}.spm.tools.fieldmap.applyvdm.data.scans(1) = cfg_dep('Realign: Estimate & Reslice: Realigned Images (Sess 1)', substruct('.','val', '{}',{REALIGN}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','cfiles'));
matlabbatch{APPLY_FIELD_MAP}.spm.tools.fieldmap.applyvdm.data.vdmfile(1) = cfg_dep('Calculate VDM: Voxel displacement map (Subj 1, Session 1)', substruct('.','val', '{}',{GET_FIELD_MAP}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','vdmfile', '{}',{1}));
matlabbatch{APPLY_FIELD_MAP}.spm.tools.fieldmap.applyvdm.roptions.pedir = 2;
matlabbatch{APPLY_FIELD_MAP}.spm.tools.fieldmap.applyvdm.roptions.which = [2 1];
matlabbatch{APPLY_FIELD_MAP}.spm.tools.fieldmap.applyvdm.roptions.rinterp = 4;
matlabbatch{APPLY_FIELD_MAP}.spm.tools.fieldmap.applyvdm.roptions.wrap = [0 0 0];
matlabbatch{APPLY_FIELD_MAP}.spm.tools.fieldmap.applyvdm.roptions.mask = 1;
matlabbatch{APPLY_FIELD_MAP}.spm.tools.fieldmap.applyvdm.roptions.prefix = 'fmap_';

%--------------------------------------------------------------------------
% Normalisation (skstruct -> standard)
matlabbatch{NORMALISATION}.spm.spatial.preproc.channel.vols = {fullfile(struct_dir, 'defaced_mprage.nii')};
matlabbatch{NORMALISATION}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{NORMALISATION}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{NORMALISATION}.spm.spatial.preproc.channel.write = [1 1];
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(1).tpm = {fullfile(tpm_dir,'TPM.nii,1')};
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(2).tpm = {fullfile(tpm_dir,'TPM.nii,2')};
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(3).tpm = {fullfile(tpm_dir,'TPM.nii,3')};
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(4).tpm = {fullfile(tpm_dir,'TPM.nii,4')};
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(5).tpm = {fullfile(tpm_dir,'TPM.nii,5')};
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(6).tpm = {fullfile(tpm_dir,'TPM.nii,6')};
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{NORMALISATION}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{NORMALISATION}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{NORMALISATION}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{NORMALISATION}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{NORMALISATION}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{NORMALISATION}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{NORMALISATION}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{NORMALISATION}.spm.spatial.preproc.warp.write = [1 1];

%--------------------------------------------------------------------------
% Coregistration (mean functional -> skstruct [bias corrected])
matlabbatch{COREGISTRATION}.spm.spatial.coreg.estimate.ref(1) = cfg_dep('Segment: Bias Corrected (1)', substruct('.','val', '{}',{NORMALISATION}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','channel', '()',{1}, '.','biascorr', '()',{':'}));
matlabbatch{COREGISTRATION}.spm.spatial.coreg.estimate.source(1) = cfg_dep('Apply VDM : Mean Image', substruct('.','val', '{}',{APPLY_FIELD_MAP}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
matlabbatch{COREGISTRATION}.spm.spatial.coreg.estimate.other(1) = {fullfile(func_dir, 'fmap_slicecorr_vol.nii')}; % using this as a dependency causes an error
matlabbatch{COREGISTRATION}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{COREGISTRATION}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{COREGISTRATION}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{COREGISTRATION}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

%--------------------------------------------------------------------------
% Write functionals to standard space
matlabbatch{WRITE_FUNCTIONAL}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{NORMALISATION}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
matlabbatch{WRITE_FUNCTIONAL}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{COREGISTRATION}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{WRITE_FUNCTIONAL}.spm.spatial.normalise.write.woptions.bb = ...
    [-78 -112 -70
    78 76 85];
matlabbatch{WRITE_FUNCTIONAL}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
matlabbatch{WRITE_FUNCTIONAL}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{WRITE_FUNCTIONAL}.spm.spatial.normalise.write.woptions.prefix = 'norm_';

%--------------------------------------------------------------------------
% Smooth functionals
matlabbatch{SMOOTHING}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{WRITE_FUNCTIONAL}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{SMOOTHING}.spm.spatial.smooth.fwhm = [6 6 6]; % use 6 mm kernel like the paper
matlabbatch{SMOOTHING}.spm.spatial.smooth.dtype = 0;
matlabbatch{SMOOTHING}.spm.spatial.smooth.im = 0;
matlabbatch{SMOOTHING}.spm.spatial.smooth.prefix = 'smooth_';

%--------------------------------------------------------------------------
% Write [bias corrected] structural to standard space
matlabbatch{WRITE_STRUCTURAL}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{NORMALISATION}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
matlabbatch{WRITE_STRUCTURAL}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Segment: Bias Corrected (1)', substruct('.','val', '{}',{NORMALISATION}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','channel', '()',{1}, '.','biascorr', '()',{':'}));
matlabbatch{WRITE_STRUCTURAL}.spm.spatial.normalise.write.woptions.bb = ...
    [-78 -112 -70
    78 76 85];
matlabbatch{WRITE_STRUCTURAL}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
matlabbatch{WRITE_STRUCTURAL}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{WRITE_STRUCTURAL}.spm.spatial.normalise.write.woptions.prefix = 'norm_';
%--------------------------------------------------------------------------

if run == 2
    spm_jobman('initcfg');
    spm_jobman('interactive',matlabbatch);
elseif run == 1
    spm_jobman('initcfg');
    spm_jobman('run',matlabbatch);
end
