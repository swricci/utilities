function [outTable] = rms_bands(y, startFreq, endFreq, fs, winl, ovlp)
    % RMS_BANDS Calculate the RMS of a signal in bands
    %   RMS_BANDS(IN_TABLE, BAND_WIDTH) calculates the RMS of a signal in
    %   bands of width BAND_WIDTH. The input table IN_TABLE must contain a
    %   column named 'Signal' with the signal to be analyzed. The output
    %   table OUT_TABLE contains the RMS values for each band.
    %
    %   Example:
    %       outTable = rms_bands(inTable, 10);
    %
    %   See also RMS, BANDPASS, TABLE.


    %% Defaults 
    if isempty(fs); fs=48000; disp('WARNING - Using 48000 Fs');  end 
    if isempty(winl); winl= 2^14; end 
    if isempty(ovlp); ovlp=0; end 
  
    winl=2^nextpow2(winl); % map to a power of 2
    
    % Calculate the number of bands
    nBands = length(startFreq);
    
    % Initialize the output table
    outTable = table('Size', [nBands, 1], 'VariableTypes', {'double'}, 'VariableNames', {'RMS'});
    
    % Calculate the band power spectrum
    [mspec,f] = sound_BandPowSpec(y,fs,winl,ovlp);
    
    % Calculate the RMS for each band
    for i = 1:nBands
        % Get the start and end indices for the band
        startIdx = startFreq(i);
        endIdx = endFreq(i);
        
        % Get the signal for the band
        a = f >= startIdx & f < endIdx;
        
        % Calculate the RMS for the band
        rmsValue = 10*log10(sum(mspec(a)));
        
        % Store the RMS value in the output table
        outTable.RMS(i) = rmsValue;
    end

    % add overall RMS to end of table
    outTable.RMS(nBands+1) = 10*log10(sum(mspec));
end