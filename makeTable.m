sceneList = readtable("/Users/swbrown/Desktop/remote_data/d_sbrown/FKNMS/data/merged_sceneTimes.csv");

% Create variable names
for b = 1: length(startFreq)
    varNames{b} = strcat('RMS_', num2str(startFreq(b)), '-', num2str(endFreq(b)));
end

varNames{length(startFreq)+1} = 'RMS_Overall';

finalTable = [];

% Loop through each scene
for s = 1:height(sceneList)
    time_win = 2;
    rtdir = "/Users/swbrown/Desktop/remote_data/";
    [y,t,fs] = plot_spectrogram('WDR', sceneList.merged_timestamp(s), time_win, rtdir, 0);

    startFreq  = [100 100 100 100 500];
    endFreq = [500 1000 3000 5000 10000];

    outTable = rms_bands(y, startFreq, endFreq, fs,[],[]);

    % Transpose the table & remove first column
    outTable = rows2vars(outTable);
    outTable = outTable(:,2:end);

    % Rename the variables
    outTable.Properties.VariableNames = varNames;

    % add column with sceneTime as column 1
    sceneTime = sceneList.merged_timestamp(s);
    outTable = addvars(outTable, sceneTime, 'Before', 1);
    finalTable = vertcat(finalTable, outTable);

end

% writetable(finalTable, '/Users/swbrown/Desktop/remote_data/d_sbrown/FKNMS/data/rms_bands.csv');

% Read in detection info
detections = readtable('/Users/swbrown/Desktop/remote_data/d_sbrown/FKNMS/output/wdr_detection_info.csv');

% read in merge scene list
merged_sceneTimes = readtable('/Users/swbrown/Desktop/remote_data/d_sbrown/FKNMS/data/.csv');