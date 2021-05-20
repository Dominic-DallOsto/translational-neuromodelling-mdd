function prepro_motionPlots(dataset_dir)
% Plot and create images of the motion parameters outputed from SPM preprocessing
% Run after preprocessing to create the plots for all subject. 
% 
% Input: 
%    datasetDir:  path to dir containing all subject data folder
% 

% data
data_dir = fullfile(dataset_dir, 'data');
subjs = dir([data_dir filesep 'sub*']); 
rp_dir = 'rsfmri/';
physio_dir = 'physio_output/';

for j = 1:length(subjs)   
    % subjects directory containing preprocessing results
    subName =subjs(j).name;
    rp_path = fullfile(data_dir, subName, rp_dir);
    physio_path = [data_dir filesep subName filesep physio_dir];
    
    if exist(fullfile(rp_path, 'rp_slicetimingcorrectedvol.txt'), 'file') && exist(fullfile(physio_path, 'multiple_regressors.txt'), 'file')
        
        % get realignment parameters from preprocessing
        rp = load(fullfile(rp_path, 'rp_slicetimingcorrectedvol.txt')); 

        % get physio motion regressors 
        glm_regressors = load(fullfile(physio_path, 'multiple_regressors.txt'));

        % create motion info for all subjects 
        motion_check.subID = cellstr(subName);
        motion_check.nOutlierRegrs = size(glm_regressors, 2) - 9; 
        motion_check.minParams = min(rp, [], 1);
        motion_check.meanParams = max(rp, [], 1);
        motion_check.meanParams = mean(rp, 1);

        if any(max(rp, [], 1) >=2) || any(min(rp, [], 1) <= -2)
            motion_check.outlier = 1;
        else 
            motion_check.outlier = 0;
        end

        % plot motion parameters
        scaleme = [-3 3];
        printfig = figure;
        set(printfig, 'Name', ['Motion parameters: subject ' subName], 'Visible', 'on');
        subplot(2,1,1);
        plot(rp(:,1:3));
        grid on;
        ylim(scaleme);  % enable to always scale between fixed values as set above
        title(['Motion parameters: shifts (in mm, XYZ)'], 'interpreter', 'none');
        subplot(2,1,2);
        plot(rp(:,4:6)*180/pi);
        grid on;
        ylim(scaleme);   % enable to always scale between fixed values as set above
        title(['Motion parameters: rotations (in dg, pitch roll yaw)'], 'interpreter', 'none'); 
        filename = ['motion_' subName '.png'];
        print(printfig, '-dpng', '-noui', '-r100', filename);  % enable to print to file
        close(printfig);   % enable to close graphic window
    else
        motion_check.subID = cellstr(subName);
        
    end
end

% save the motion stats of all subjects 
save(fullfile(pwd, 'motion_check.mat'), 'motion_check')
   
end 
