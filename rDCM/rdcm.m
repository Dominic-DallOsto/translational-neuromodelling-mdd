% rdcm()


% Y should be in correct format straight from SPM pre-processing
% U is "switched off" by setting all input parameters to zero (second parameter)
% No args (third parameter)
DCM = tapas_rdcm_model_specification(struct('y',timeseries,'dt',2.5), [], []);

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

%% model estimation

% get time
currentTimer = tic;

% run rDCM analysis with sparsity constraints (performs model inversion)
% last parameter: (1) original, (2) with sparsity constraints
[output, options] = tapas_rdcm_estimate(DCM, type, options, 1);

% output elapsed time
toc(currentTimer)
