function plot_detections(site, sceneTime,)
    
    % now find the original tif file to plot
    % the files are stored in a complicated path (how it was downloaded from
    % Planet)
    m = 'jun';
    site = 'wdr';
    sceneDir = strcat("D:\fknms\FKNMS_project\imagery\",site,"\",site,"_2019_",m,"_psscene3band_visual\files\");
    img_name = fullfile(sceneDir,strcat(sceneName,".tif"));
    
    % now find the detections that are from the selected scene
    currDetections = fknms(contains(fknms.chipName,sceneName),:);
    
    % read in image
    [A,RA] = readgeoraster(img_name);
    
    % plot it all
    figure; mapshow(A(:,:,1:3),RA);
    hold on; mapshow(currDetections.x,currDetections.y,'DisplayType','point')
    
    %% Do some plotting in geographic (lat/lon) coordinates
    % change imagery from projected to geographic (lat/lon) coordinates
    %https://www.mathworks.com/help/map/project-and-display-raster-data.html
    p = RA.ProjectedCRS;
    [x,y] = worldGrid(RA);
    [lat,lon] = projinv(p,x,y);
    
    figure; geoshow(lat,lon,A(:,:,1:3));
    hold on; geoshow(currDetections.lat,currDetections.lon,'DisplayType','point')

    v