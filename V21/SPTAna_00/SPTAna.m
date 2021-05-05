function SPTAna(filesave, ... 
    fname,... 
    filecoords,... 
    filecounts,... 
    pixel,...      
    timeinterval,...
    lambda,...
    numericalAperture,...
    localizationStd,...
    Astgmax,...
    Astgmin,...
    FWHMmax,...
    FWHMmin,...
    Intmin,...
    SNRmin,...
    MaxGapClosing,...
    LongTrackSize,...
    DarkIntensityCamera,...
    initialFrame,...
    finalFrame)

%Identify particles on a series of frames using the localization and the number of particles per frame
% obtained from the program rapidStorm
%%
%INPUT:
%filesave:  file name to save results.
%fname: name of the tif file to be analyzed.
%filecoords: name of the TEXT file where the localization data is located. It has 8 columns (x in nanometer,y in nanometer,frame,
    %emission stregth in A/D count,PSF width x in nanometer, PSF width y in
    %nanometer, fitresidues, LocalBackground. This file is the exit of rapidStorm program analyzing a series of images in a file *.tif
%filecounts: name of the TEXT file with the number of localization per frame. This file is the exit of rapidStorm program with 2 collumns (frame, number of localization per frame) 
%pixel: pixel size used in for the image measurement. (nanometer)
%timeinterval: time interval between frames (exposure time + reading time). (miliseconds)
%lambda: emission wavelength of the fluorescent molecule. (nanometer)
%numericalAperture: numerical aperture (NA) of the objective used. 
%localizationStd: radius used to performe tracking, all particles inside this radius will be considered the same particle. (nanometer)
%Astgmax: maximum value of Astigmatism for a localization to be considered valid. 
%Astgmin: minimum value of Astigmatism for a localization to be considered valid.
%FWHMmax: maximum value of FWHM for a localization to be considered valid. (namometer) 
%FWHMmin: minimum value of FWHM for a localization to be considered valid. (namometer) 
%Intmin: minimum value of Intensity for a localization to be considered valid. (A/D counts) 
%SNRmin: minimum value of Signal to Noise Ration for a localization to be considered valid.  
%MaxGapClosing: maximum frame gap to be closed during particle tracking. (frame) 
%LongTrackSize: minimum track size for a particle to be considered long track.(frame) 
%initialFrame: initial frame to be analyzed.  
%finalFrame: final frame to be analyzed.  


%%
% OUTPUT:

%% Created by CVS - July 04/2018 
%% UPDATES by: 
%CVS July 10/2018
%CVS July 12/2018
%CVS July 15/2018
%CVS July 17/2018: Put filters as optional in the analysis. Create a
%function to calculate the mean coordenates, edit PSF filter function,
%create a function to calculate PSF with equipment parameters. 
%
%CVS July 19/2018 v15: 1.Checking if tracking works with a simulated image. 
%                      Tracking is OK. It was just not count the 
%                       non-consecutives links to print the numbers of links. 
%                       Now it is fixed.
%                      2.Add an PSF distribution analysis that is used to
%                      filter the particles and also to track them. 
%CVS August 03/2018 v15: Added a function to calculate the intensity in the
%image
%
%CVS Feb 2019 v20: 1.print trajectory matrix to check if program can trace
%one particle if we increase the psfError that is used to track the
%particle.
%                  2.include filename in ascii salved files
%
%CVS March 2019 v20: Add new variable for localization uncertainty. Print output to a file
%
%CVS June 2019 v21: - Remove assignin to save.
%                   - Group variable to be inside structures. 
%                   - Include time counter. 
%CVS March 2020 v21:- Remove assignin to save.
%                   - Group variable to be inside structures. 
%                   - Time counter. 
%                   - Astigmatism Filter with max and min from
%                   Input
%                   - FWHM filter with max and min from Input.
%                   - Intensity filter with min from Input
%                   - SNR Filter with min from input
%CVS January 2021 v21.1: -add MSD calculation and diffusion
%% Step 1 - Creating output for .mat file, Saving INPUTS into struct and LOADING data:

Input=struct;
Input.Save=filesave;
Input.ImageName=fname;
Input.Localizations=filecoords;
Input.Counts=filecounts;
Input.PixelSize=pixel;
Input.dT=timeinterval;
Input.Lambda=lambda;
Input.NA=numericalAperture;
Input.LocalizationRadius=localizationStd;
Input.SaveMat=sprintf('%s.mat',filesave);
Input.Astgmax=Astgmax;
Input.Astgmin=Astgmin;
Input.FWHMmax=FWHMmax;
Input.FWHMmin=FWHMmin;
Input.Intmin=Intmin;
Input.SNRmin=SNRmin;
Input.MaxGapClosing=MaxGapClosing;
Input.LongTrackSize=LongTrackSize;
Input.DarkIntensityCamera=DarkIntensityCamera;

% Check if input contain an initial and/or a final frame to be analyzed:
if nargin<19
    Input.finalFrame=-1;
    Input.initialFrame=0;
elseif nargin<20
    Input.finalFrame=-1;
elseif nargin==20
    Input.finalFrame=finalFrame;
    Input.initialFrame=initialFrame;
end

save(Input.SaveMat,'Input','-v7.3');

% Creating output file and start counting time:

filenameout = sprintf('%s_output.txt',filesave);
Input.fileID = fopen(filenameout,'w');

fprintf(Input.fileID,'\nSPT Program v.21.1 - 2021.01.27.');
t1 = datestr(now,'mmmm dd, yyyy HH:MM:SS AM');
fprintf(Input.fileID,'\n%s',t1);
t1n=now;

% Loading Raw Data

[ImageStr,InputData,Input] = SPTAna_01(Input); 

Input.numFrames=ImageStr.nframes;

save(Input.SaveMat,'Input','-append','-v7.3');

%% Step 2 - Preparing Data 

[TheoreticalData,InputData,DataPerFrame] =SPTAna_02(Input,InputData);
save(Input.SaveMat,'InputData','TheoreticalData','-append');


%% Step 3 - Filtering Localizations to remove noise

[DataFilterAstg,DataFilterFWHM,DataFilterInt,DataFilterSNR] = SPTAna_03(Input,DataPerFrame); % removes from the PSF the values that are bigger than 2 x the Rayleigh resolution
save(Input.SaveMat,'DataFilterAstg','DataFilterFWHM','DataFilterInt','DataFilterSNR','-append');

DataFilter=DataFilterSNR;

%% Step 4 - Tracking Particles   

[ ParticleData, Tracks] = SPTAna_04(Input,DataFilter);
save(Input.SaveMat,'Tracks', 'ParticleData', '-append');


%% Step 5 - Long track Particle Selection  

 ParticleData_MinTrack=SPTAna_05(ParticleData, Input);
 save(Input.SaveMat, 'ParticleData_MinTrack', '-append');

%%
fprintf(Input.fileID,'\nFinished!.\n');

t2 = datestr(now,'mmmm dd, yyyy HH:MM:SS AM');
fprintf(Input.fileID,'\n%s',t2);
t2n=now;

time_diff = t2n - t1n;
dt2=datestr(time_diff,13);
fprintf(Input.fileID,'\n Total Elapsed time: %s',dt2);


fclose(Input.fileID);

