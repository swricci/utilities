function [y,t,fs, mpsec, f] = plot_spectrogram(site, sceneTime, time_win, rtdir, plt = 1)
    % Plot sound imagery for a given site and time window
        % site: site name
        % sceneTime: time of the scene
        % time_win: number of minutes to +/- to sceneTime
        % rtdir: root directory of the data
        % plt: plot flag  
        
    % Dependencies
        % getST500_Keys.m
        % sound_MSPEC.m


    % Get start time and duration of data to pull
    sTime = datevec(sceneTime - minutes(time_win));
    dur = 2*time_win*60; % in seconds

    % Pull the data
    [y,t,fs] = getST500_Keys(site, sTime, dur, rtdir);

    

    % Make a spectrogram

    % Make a map of the scene and detections





