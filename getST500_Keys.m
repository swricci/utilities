function [y, t, fs]=getST500_Keys(site, st, nsec, tvec, rtdir) 
%
% FUNCTION: getST500_Keys
% [y, t, fs]=getST500_Keys(site, st, nsec, tvec, rtdir) 
%
%
% This function exacts a resampled (@48,000 Hz) data segment 
% from the NOAA FK datasets (Deployments 1 - 5.  It uses re-computed 
% start and end times for each ST500 file, calculated with the true 
% sample rate for each file. 
% 
%
% BASIC USAGE  
% [y, t, fs]=getST500_Keys(site_name, stattime_vector, nsec_to_return)
% [y, t, fs]=getST500_Keys('FK01', [2019,2,1,0,0,0.5], 12)
%       would return 12 second of data at 48 kHz sample rate, 
%       starting at 1 Feb 2019 00:00:00.5;  The vector t would a datetime
%       object (UTC) 
%
% [y, t, fs]=getST500_Keys('FK01', [2019,2,1,0,0,0.5], 12, 'posix','Z:/FKNMSfolder')
%       would return 12 second of data at 48 kHz sample rate, 
%       starting at 1 Feb 2019 00:00:00.5;  
%       'posix' specifies that the vector t would a in seconds since 1970; 
%       'Z:/FKNMSfolder' is the foder where FKNMS_01.... FKNMS_05
%       folders are. 
%
% INPUTS 
% site may be 
% 'FK01' or 'WDR' 
% 'FK02' or 'ESB'
% 'FK03' or 'NFS'
% 'FK04' or 'SBR' 
%
% st - starttime_vector [yr, mo, da, hh, mm, sc] or a datetime object. 
%
% nsec - # sec to return.  Cannot span > 2 files (where each file is ~6 hours) 
%   since the function is resampling, recommend nsec <= 3600 (1 hr)  
% 
% rtdir  - the directory path which contains folders FKNMS_01.... FKNMS_05
%          along with the FKNMS_tt folder with one time table file per site
%          (i.e., FK01_tt.... FK04_tt). 

%   '/Volumes/G5/'
%   '/Volumes/SancSndBU1/'
%   '/Volumes/SancSndBU2/'
% 
% tvec    -  type of time vector to  return 
%            'datetime' - date time object (default) 
%            'posix' - since since 1970
%            'matdays' - matlab days 
%            'secs' - since since start of clip 
%
% OUTPUTS 
% y = resampled and demeaned vector of response corrected data in microPa (uPa) 
% t is a vector of time in the format specified 
% fs - will always be 48,000 
%
%
% drbohnen@ncsu.edu 
%  NC State 
% last updated 01 April 2023 

% set the defaults 
if nargin < 5
rtdir='U:/'; 
end
if nargin < 5
tvec='dtobj';
end

% convert/calc start and stop times in days for checking avaialability 
if isdatetime(st)==0 
st=datetime(st);  % this will be in days. 
end

et=st+nsec/86400; % this is in days 

% figure out which site is being requested 
S1 = sum(strncmp(site, {'FK01', 'fk01', 'WDR', 'wdr','West', 'west' 'Fk01', '01','1'},4)); if S1 > 0; S1 =1; end 
S2 = sum(strncmp(site, {'FK02', 'fk02', 'ESB',  'esb', 'East', 'east', 'Fk02', '02','2'},4)); if S2 > 0; S2 =1; end 
S3 = sum(strncmp(site, {'FK03', 'fk03', '9FS',  'nfs', 'NFS', 'Nine', 'nine', 'Fk03', '03','3'},4)); if S3 > 0; S3 =1; end 
S4 = sum(strncmp(site, {'FK04', 'fk04', 'SBR',  'sbr', 'Somb', 'Fk04', '04','4'},4)); if S4 > 0; S4 =1; end 


% set the data paths and gains 
if S1==1  
      load(fullfile(rtdir,'FKNMS_tt/FK01_tt.mat'),'FK01_tt');  % table of start times for WDR  
      tt=FK01_tt; % generric time table (tt) name to simply coding later 
       slabel='WDR'; 
elseif S2==1 
      load(fullfile(rtdir,'FKNMS_tt/FK02_tt.mat'),'FK02_tt');  % table of start times for WDR  
      tt=FK02_tt; % generric time table (tt) name to simply coding later 
      slabel='ESB'; 
elseif S3==1 
      load(fullfile(rtdir,'FKNMS_tt/FK03_tt.mat'),'FK03_tt');  % table of start times for WDR  
      tt=FK03_tt; % generric time table (tt) name to simply coding later 
       slabel='NFS'; 
elseif S4==1 
      load(fullfile(rtdir,'FKNMS_tt/FK04_tt.mat'),'FK04_tt'); 
      tt=FK04_tt; % generric time table (tt) name to simply coding later 
      slabel='SBR'; 
else 
   error('Sorry but I do not recognize this site as part of the NOAA-Navy FKNMS dataset')  
end

if sum([S1,S2,S3,S4]) > 1 
 error('Sorry can not uniquely identify whch site you want')     
end

fs=48000; 
a=find(tt.ST < st,1,'last'); 
b=find(tt.ET > st+seconds(nsec),1,'first'); 

if isempty(a) || isempty(b)
    y=NaN;  t=NaN; fs=NaN; 
    error('outside the limits of data this station')
end


if a==b 
file=char(tt.fileS(a)); 
c=strsplit(file,'_');
sn=str2double(c(4))


file2getA=fullfile(rtdir,strcat('FKNMS_',c(3)),strcat(c(2),'_',c(3),'_',slabel),c(4),tt.fileS(a));

          indST=ceil(seconds(st-tt.ST(a)).*tt.fs_calc(a)); % time * real fs = start index within file
          indET=floor(seconds(et-tt.ST(a)).*tt.fs_calc(a)); % time * real fs = start index within file
          [data,~]=audioread(char(file2getA),[indST,indET]); % extract the data 
          data=data-mean(data); % demean the data - not zero meaned 
          clipstart=seconds((indST-1)/tt.fs_calc(a)) + tt.ST(a);  % calculate the actual start time 
          treal=clipstart + (0:1:length(data)-1)*seconds(1/tt.fs_calc(a)); % actual time in file 1 
          t=clipstart:seconds(1/fs):treal(end); % resampled time to return 
          y=interp1(treal,data,t,'pchip');  % resample the data 

elseif b - a == 1 % spans two files 

if tt.ST(b)-tt.ET(a) > seconds(0.001)
     disp('Sorry this request falls within a data gap')
        y=NaN;  t=NaN; fs=NaN;

else 

file=char(tt.fileS(a)); 
c=strsplit(file,'_');
sn=str2double(c(4));

file2getA=fullfile(rtdir,strcat('FKNMS_',c(3)),strcat(c(2),'_',c(3),'_',slabel),c(4),tt.fileS(a));
          indST=ceil(seconds(st-tt.ST(a)).*tt.fs_calc(a));  % index to start reading at 
          [data1,~]=audioread(char(file2getA),[indST,tt.Scount(a)]);  % extract the data from end of first file 
          clipstart1=seconds((indST-1)/tt.fs_calc(a)) + tt.ST(a);  % calculate the actual start time 
          treal1=clipstart1 + (0:1:length(data1)-1)*seconds(1/tt.fs_calc(a)); % actual time in file 1 
          
            %
 file=char(tt.fileS(b)); 
 c=strsplit(file,'_');
            file2get2B=fullfile(rtdir,strcat('FKNMS_',c(3)),strcat(c(2),'_',c(3),'_',slabel),c(4),tt.fileS(b));
            indET=floor(seconds(et-tt.ST(b)).*tt.fs_calc(b));
            [data2]=audioread(char(file2get2B),[1,indET]);   
            treal2=tt.ST(b) + (0:1:length(data2)-1)*seconds(1/tt.fs_calc(b));% actual time in file 2 
            
            % combine the data and time vector
            
            data=[data1; data2]; treal=[treal1,treal2]; 
            data=data-mean(data); % demean the data  

          t=treal(1):seconds(1/fs):treal(end); % resampled time to return 
          y=interp1(treal,data,t,'pchip');  % resample the data

          disp('getting data that spans a break... you are welcome')
end

else 
         error('Me thinks you ask for too much data ... request can only span 2 files')    
      
end

if isnan(y)==0
cal=getcal(sn); 
y=y*cal; 

switch tvec 
    case 'posix'
     t=posixtime(t); 
    case 'secs'
      t=posixtime(t);  t=t-t(1); 
    case 'matdays'
       t=datemum(t);
    case 'datetime'
        % do nothing already in datetime 
    otherwise
        % default to datetime 
end

end


function cal=getcal(sn)
      if sn==671359016
          gain=177.1-1.8;  cal=10.^(gain/20);  
      elseif sn==671117353
          gain=177.3-1.8;  cal=10.^(gain/20);   
      elseif sn==671354921
          gain=177.3-1.8;  cal=10.^(gain/20);
      elseif sn==470032451
          gain=179.1-1.8;  cal=10.^(gain/20); 
      elseif sn==5441
          gain=177.2-1.8;  cal=10.^(gain/20);  
      elseif  sn==5424
          gain=177.1-1.8;  cal=10.^(gain/20); 
      else
          disp('cannot determine gain')
      end
end


end

