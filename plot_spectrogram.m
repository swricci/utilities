function [y,t,fs] = plot_spectrogram(site, sceneTime, time_win, rtdir)
    % Plot sound imagery for a given site and time window
        % site: site name
        % sceneTime: time of the scene
        % time_win: number of minutes to +/- to sceneTime
        % rtdir: root directory of the data  
        
    % Dependencies
        % getST500_Keys.m


    % Get start time and duration of data to pull
    sTime = datevec(sceneTime - minutes(time_win));
    dur = 2*time_win*60; % in seconds

    % Pull the data
    [y,t,fs] = getST500_Keys(site, sTime, dur,'datetime', rtdir);

    % Make a spectrogram

    [~,F,T,Pxx]=spectrogram(y,2^12,2^11,[],fs); %0.05sec windows, 0% overlap

    figure;
    imagesc(T,F,10*log10(Pxx)); axis xy; xlabel('Time (sec)'); 
    caxis([40,90]);  
    ylim([0 5000]);
    ylabel('Frequency (kHz)'); title(datestr(sceneTime));










end





