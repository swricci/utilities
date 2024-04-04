sceneList = readtable("/Users/swbrown/Desktop/remote_data/d_sbrown/FKNMS/data/merged_sceneTimes.csv");

t = 60;
time_win = 2;
rtdir = "/Users/swbrown/Desktop/remote_data/";
[y,t,fs,f] = plot_spectrogram('WDR', sceneList.merged_timestamp(t), time_win, rtdir);

