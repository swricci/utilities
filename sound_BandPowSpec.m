function [mspec,f]=sound_BandPowSpec(y,fs,winl,ovlp)
%
% [mspec,f]=sound_BandPowSpec(y,fs,winl,ovlp)
%
% The function sound_BandPowSpec returns frequency band power by averaging
% 'winl' length data segments within the pressure time series y 
% 
% INPUT 
% y = pressure corrected time series uPa
% fs = sample rate 
% winl = number of data points in each winldow 
%        this should be a power of 2 (making winl = NFFT)
%        For example: If you want to average ~1/4 sec duration winldows use 
%        2^netpow2(0.25*fs); if not program will choise nextpow2 for you 
% ovlp = # points of overlap in FFT calcs; must to < winl  
%        if omiitd - default is zero 
% 
% OUTPUT 
% mspec = band power spectrum averaged over all windows in data y (uPa^2)
%         Use 10*log10(mspec) to convert to dB re 1 uPa^2. 
%         To convert to true PSD, normalize by freqency resolution 
%         PSD = 10*log10(mspec/(fs/winl)) 
% f = frequency bins corresponding to mspec 
% 
% NOTES:
%  1. Spectrum is scalculated using Hanning winldow 
%  2. The spectrum is scaled such that the sum of the spectral bins is 
%   equal to the variance (power) in the timeseries data.  So one can 
%   sum the mspec over a range of frequencies to get an estimate of the 
%   sound pressure level in that band. 
%     For example to find SPL in the 100-20000 Hz band: 
%     a= find(f > 100 & f < 20000); dBspl= 10*log10(sum(mspec(a))); 
%
%  3. Returned spectra is in uPa.^Hz per bin (NOT dB)
%
% Validation against MATLAB's pwelch: 
%   [mspec,f]=sound_MSPEC(y,48000,2^14,0);
%   [PSD,f] = pwelch(y,hanning(2^14),0,2^14,48000,'onesided','psd');
%   freq resolution = 48000/2^14  
%   mean(mspec./PSD) = freq resolution (2.9297) 
% 
% Del Bohnenstiehl - NCSU 
% Last modified 6 Dec 2022   
% drbohnen@ncsu.edu 


%% Defaults 

if nargin < 3 
  disp('not enough arguemnts; NEED: y,fs,winl,ovlp') 
   return 
end
if isempty(fs); fs=48000; disp('WARNING - Using 48000 Fs');  end 
if isempty(winl); winl= 2^14; end 
if isempty(ovlp); ovlp=0; end 

winl=2^nextpow2(winl); % map to a power of 2

%% Break the time series up into as many segdur pieces as possible and store 
y=y-mean(y);  % demean the time series 
x=buffer(y,winl,ovlp,'nodelay');   
if x(end)==0; x(:,end)=[]; end  % if last colum is zero padded delete. 
[r,Nwin]=size((x)); 
msub=repmat(mean(x,1),r,1); % calculate the mean of each column 
x=x-msub; % remove the mean of each column

%% now calculate the average spectra 
wo=hanning(r); % hanning winldow 
zo=x.*repmat(wo,1,Nwin); % apply winldow to each segment   
                  %  winl = NFFT 
Y=fft(zo,winl,1); % two sided FFT opperating on each column 
po=2*abs(Y).^2/(winl*sum(wo.^2));   % scale for PSD accounting for window 
po=po(1:ceil(winl/2)+1,:); po(1,:)=po(1,:)./2;  % backout DC doubling 
[prows,~] = size(po);        % # rows in po. 
m=0:1:prows-1; f=m*fs/winl;  % define the frequency axis
mspec=mean(po,2);           % average spectra 

