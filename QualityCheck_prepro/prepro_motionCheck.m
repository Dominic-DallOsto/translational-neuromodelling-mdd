function prepro_motionCheck(dataset_dir)
% Plot and create images of the motion parameters outputed from SPM preprocessing
% Run after preprocessing to create the plots for all subject. 
% 
% Input: 
%    datasetDir:  path to dir containing all subject data folder
% 

% data
data_dir = fullfile(dataset_dir, 'data');
subjs = dir([data_dir filesep 'sub-*']); 
rp_dir = 'rsfmri';
physio_dir = 'physio_output';

subject_index = 0;
motion_check = struct();

for j = 1:length(subjs)   
    % subjects directory containing preprocessing results
    subName =subjs(j).name;
    rp_path = fullfile(data_dir, subName, rp_dir);
    physio_path = [data_dir filesep subName filesep physio_dir];
    
    if exist(fullfile(rp_path, 'rp_slicecorr_vol.txt'), 'file') && exist(fullfile(physio_path, 'multiple_regressors.txt'), 'file')
        subject_index = subject_index + 1;
		
        % get realignment parameters from preprocessing
        rp = load(fullfile(rp_path, 'rp_slicecorr_vol.txt')); 

        % get physio motion regressors 
        glm_regressors = load(fullfile(physio_path, 'multiple_regressors.txt'));

        % create motion info for all subjects 
        motion_check(subject_index).subID = cellstr(subName);
        motion_check(subject_index).nOutlierRegrs = size(glm_regressors, 2) - 9; 
        motion_check(subject_index).minParams = min(rp, [], 1);
        motion_check(subject_index).maxParams = max(rp, [], 1);
        motion_check(subject_index).meanParams = mean(rp, 1);
        motion_check(subject_index).outlier = any(max(abs(rp), [], 1) >=2);

        % plot motion parameters
        scaleme = [-3 3];
        printfig = figure('Name', sprintf('Motion parameters: subject %s', subName), 'visible', 'off');
        subplot(2,1,1);
        plot(rp(:,1:3));
        grid on;
        ylim(scaleme);  % enable to always scale between fixed values as set above
        title('Motion parameters: shifts (in mm, XYZ)', 'interpreter', 'none');
        subplot(2,1,2);
        plot(rp(:,4:6)*180/pi);
        grid on;
        ylim(scaleme);   % enable to always scale between fixed values as set above
        title('Motion parameters: rotations (in dg, pitch roll yaw)', 'interpreter', 'none'); 
		filename = fullfile(rp_path, sprintf('motion_%s.png', subName));
        print(printfig, '-dpng', '-noui', '-r100', filename);  % enable to print to file
        close(printfig);   % enable to close graphic window
    else
        motion_check.subID = cellstr(subName);
        
    end
end

% print motion params for each subject
printfig = figure('Name', 'Motion parameter stats', 'visible', 'off');
for motion_param = 1:6
	subplot(3,2,motion_param);
	title(sprintf('Motion params %d', motion_param));
	hold on
	plot(cellfun(@(params) params(motion_param), {motion_check.minParams}));
	plot(cellfun(@(params) params(motion_param), {motion_check.maxParams}));
	plot(cellfun(@(params) params(motion_param), {motion_check.meanParams}));
	hold off
end
subplot(3,2,1)
legend('min','max','mean')
subplot(3,2,5)
xlabel('subject number')
subplot(3,2,6)
xlabel('subject number')
print(printfig, '-dpng', '-noui', '-r100', fullfile(data_dir, 'motion_regressor_stats.png'));
close(printfig);

% print number of outlier regressors for each subject
printfig = figure('Name', 'Regressor outliers', 'visible', 'off');
plot([motion_check.nOutlierRegrs]);
title('Number of regressor outliers');
xlabel('subject number')
print(printfig, '-dpng', '-noui', '-r100', fullfile(data_dir, 'regressor_outliers.png'));
close(printfig);

% save the motion stats of all subjects 
save(fullfile(data_dir, 'motion_check.mat'), 'motion_check');
   
end 
