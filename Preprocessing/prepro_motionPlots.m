function prepro_motionPlots(datasetDir)

% Plot and create images of the motion parameters outputed from SPM preprocessing
% Run after preprocessing to create the plots for all subject. 
% 
% Input: 
%    datasetDir:  path to dir containing all subject data folder
% 

% check paths 
dpath = datasetDir; 
cd(dpath)
subjs = dir([pwd filesep 'sub*']); 
fpath = 'rsfmri/';
k = 0;
motion_outliers = {};

for j = 1:length(subjs)
    subName =subjs(j).name;
    
    % subjects directory of functional scans
    ipath = dir([dpath filesep subName filesep 'ses*']);
    ipath = [dpath filesep subName filesep ipath.name filesep fpath];
    cd(ipath)
    
    % read in rp file 
    rpfile = dir('rp_*.txt');
    rp = load(rpfile.name); 
    
    % recognize if motion is larger then 1 voxel (2x2x2)
    max_motion = max(rp, [], 1);
    min_motion = min(rp, [], 1);
    
    if any(max_motion >=2) || any(min_motion <= -2)
       motion_outliers(k) = cellstr(subName);
       k = k+1;
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
    mydate = date;  
    filename = ['motion_' subName '.png'];
    print(printfig, '-dpng', '-noui', '-r100', filename);  % enable to print to file
    close(printfig);   % enable to close graphic window
    
    clear rp*
    cd(dpath)  
end

% write outliers as txt
fID = fopen('motion_outliers.txt', 'w');
fprintf(fID, [cell2mat(motion_outliers)  '\n']);
    
end 
