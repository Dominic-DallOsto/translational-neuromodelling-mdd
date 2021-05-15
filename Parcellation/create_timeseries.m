function create_timeseries(datasetDir, subID, atlasFile, nameFile)
% function extracts the timeseries from multiple ROIs defined in a label
% atlas 
%
% Inputs
%   datasetDir: path to folder of subjects
%   subID:      int 
%   atlasFile:  File containing all ROI with different labels (.nii)
%   nameFile:   File containing all the names to the ROI (.txt)

dataDir = fullfile(datasetDir, 'data\', sprintf('sub-%04d', subID)); 
func_dir = fullfile(dataDir, 'rsfmri\'); %Specify path to SPM file (GLM output)

% TODO 
nMasks = 379;
fileID = fopen(nameFile,'r');
masksNames = fscanf(fileID,'%s');

for i = 1:nMasks
    %-----------------------------------------------------------------------
    % Job saved on 15-May-2021 18:39:36 by cfg_util (rev $Rev: 7345 $)
    % spm SPM - SPM12 (7487)
    % cfg_basicio BasicIO - Unknown
    %-----------------------------------------------------------------------
    matlabbatch{1}.spm.util.voi.spmmat = {fullfile(func_dir, 'SPM.mat')};
    matlabbatch{1}.spm.util.voi.adjust = 0;
    matlabbatch{1}.spm.util.voi.session = 1;
    matlabbatch{1}.spm.util.voi.name = masksNames(i);
    matlabbatch{1}.spm.util.voi.roi{1}.label.image = {atlasFile};
    matlabbatch{1}.spm.util.voi.roi{1}.label.list = i;
    matlabbatch{1}.spm.util.voi.expression = 'i1==1';
    
    % save and run single mask batch 
    spm_jobman('run', matlabbatch)
    clear matlabbatch 
end

end
