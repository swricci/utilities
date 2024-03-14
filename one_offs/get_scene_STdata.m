%% Generate scene times 
% Merge scenes that are wihtin a couple s of each other

%mergedTimes = readtable("../../output/merged_sceneTimes.csv");

%% Pull acoustic data (TEST)
% +/- 2 minutes from every scene or merges scene
% save y for each file

% Set directory for FKNMS files
rtdir = '~/Desktop/remote_data';

% merged scene times are datetimes
m = 1;
sTime = datevec(datetime([2019 04 15 15:38:00]) - minutes(2));
dur = 60 * 4; % four minutes
site = 'FK01';
[y,t] = getST500_Keys(site,sTime,dur,rtdir = rtdir);



%% Pull acoustic data

% run through this so that we can save the "y" for every site in the test
% images - this is so we can run it when we are away from the harddrives.
% for m = 1:height(mergedTimes)
%     sTime = datevec(mergedTimes.merged_timestamp(m) - minutes(2));
%     dur = 60 * 4; % four minutes
%     site = 'FK01';
%     [y,t] = getST500_Keys(site,sTime,dur,rtdir = rtdir);

%     mergedTimes.y{m} = y;
%     mergedTimes.t{m} = t;
    
%     y = [];
%     t = [];
% end

% save('output/mergedTimes.mat', 'mergedTimes');
