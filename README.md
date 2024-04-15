# Utilities

## Directory Structure

utilities
one-offs

## DeSCRIPTions

Following are the `MATLAB` and `python` scrips used for various purposes.

Script Name | Description | Inputs | Outputs
-----|-----|-----|-----|
getST500_Keys.m | Pulls acoustic data from all NOAA deployments. | site, start time, duration, data directory | y, t, fs
get_scene_STdata.m | Pulls +/- 2 min of data for every PlanetScope scene time | list of scene times, data directory | mat file of y, t for every scene time
find_boat_ranges.ipynb | Data cleaning of verified detections, determines distance to NOAA hydrophone from each detection (site = WDR) | NOAA acoustic vessel detections, planet detections | none
sound_MSPEC.m | Returns mean spectra of pressure corrected data | y, fs, window length, overlap | mean power spectrum, frequency bins
plot_spectrogram.m | Plots a spectrogram for an input time and location from the SanctSound project | site, start_time, time window (+/-), data directory, plot (on = 1) | plots a figure, returns y, t, fs (using getST500_Keys)
makeTable.m | Calculates RMS in provided frequency bands for a list of times. Depends on rms_bands function | time list | saved csv file
rms_bands.m | Calculates RMS in given frequency bands for a given time. Depends on sound_BandPowSpec.m function | pressure corrected signal, list of start frequencies and corresponding end frequencies | table with RMS values
sound_BandPowSpec.m | Returns frequency band power by averaging 'winl' length data segments within the pressure time series | y, fs, window length, overlap | band power spectrum, frequency bins corresponding to mspec




## Usage

1. Pull repo
2. Create new python environment using provided environment.yml file.

`conda env create -f environment.yml`

3. Establish connection to the data computer (newmadrid).
4. Update any paths 
