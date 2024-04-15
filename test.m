% Read in list of scenes
sceneList = readtable("/Users/swbrown/Desktop/remote_data/d_sbrown/FKNMS/data/merged_sceneTimes.csv");

% Pick a scene to look at
s = 48;
time_win = 2;
rtdir = "/Users/swbrown/Desktop/remote_data/";

[y,t,fs] = plot_spectrogram('WDR', sceneList.merged_timestamp(s), time_win, rtdir);

%