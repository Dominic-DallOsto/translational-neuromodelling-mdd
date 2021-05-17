function run_rDCM(datasetDir, subID, TR)

dataDir = fullfile(datasetDir, 'data', sprintf('sub-%04d',subID));
data = load(fullfile(dataDir, 'GLM_output', 'extracted_timeseries.mat'));
% Y should be in correct format straight from SPM pre-processing
% U is "switched off" by setting all input parameters to zero (second parameter)
% No args (third parameter)
DCM_input = struct('y',bandpass_filter_data(data.timeseries, 0.01, 0.08, TR));
DCM = tapas_rdcm_model_specification(DCM_input, [], []);

%% model estimation


% specify the options for the rDCM analysis - from TAPAS rDCM tutorial
options.SNR             = 3; % signal-to-noise ratio of synthetic fMRI data (for simulations)
options.y_dt            = 2.5; % repetition time (TR)
options.p0_all          = 0.15;  % single p0 value (for computational efficiency) - only relevant for rDCM with sparsity constraints
options.iter            = 100; % number of permutations (of regressors) per region - only relevant for rDCM with sparsity constraints
options.filter_str      = 5; % ?
options.restrictInputs  = 1;  % (1) regions that recieve driving inputs are known/fixed as specified in DCM.c or
                              % (0) prune connectivity and driving input
                              % parameters simultaneously from full A- and
                              % C-matricies (only relevant for rDCM with
                              % sparsity constraints)
                              
% run a simulation (empirical) analysis
type = 'r';

% get time
currentTimer = tic;

% run rDCM analysis with sparsity constraints (performs model inversion)
% last parameter: (1) original, (2) with sparsity constraints
[output, options] = tapas_rdcm_estimate(DCM, type, options, 1);

% output elapsed time
toc(currentTimer)

dcm_dir = fullfile(dataDir, 'rDCM');
if ~exist(dcm_dir, 'dir')
	mkdir(dcm_dir)
end
save(fullfile(dcm_dir, 'dcm_output.mat'), 'output');
save(fullfile(dcm_dir, 'dcm_options.mat'), 'options');

