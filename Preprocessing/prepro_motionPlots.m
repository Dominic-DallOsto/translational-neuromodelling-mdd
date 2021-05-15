clear
% plot and create images of the motion parameter from SPM preprocessing

dpath = 'C:\Users\sarah\Documents\university\NSC\0_SS21\TNM\project'; % CHECK PATH dir to subject data  
cd(dpath)
subjs = dir([pwd filesep 'sub*']); 
fpath = 'rsfmri/';                  

for j = 1:length(subjs)
    subName =subjs(j).name;
    
    % subjects directory of functional scans
    ipath = dir([dpath filesep subName filesep 'ses*']);
    ipath = [dpath filesep subName filesep ipath.name filesep fpath];
    cd(ipath)
    
    % read in rp file 
    rpfile = dir('rp_*.txt');
    
    % plot motion parameters
    rp = load(rpfile.name); 
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
    filename = ['motion_sub_' subName '.png'];
    motname = [ipath filesep 'motion_sub_' sprintf('%02.0f', j) '_' mydate '.png'];
    print(printfig, '-dpng', '-noui', '-r100', filename);  % enable to print to file
    close(printfig);   % enable to close graphic window
    
    clear rp*
    cd(dpath)  
end
