%%RUN SPT analysis as usual

SPTAna('SPTana_test_17_',...  %fileName to save results.
    'results100particles_1sPSF584nm.tif',... %name of the tif file to be analyzed.
    'Loca.txt',... %name of the TEXT file where the localization data is located.
    'counts.txt',... %name of the TEXT file with the number of localization per frame.
    160,... %pixel size used in for the image measurement. (nanometer)
    1000,... %time interval between frames (exposure time + reading time). (miliseconds)
    584,... %emission wavelength of the fluorescent molecule. (nanometer)
    1.40,... % numerical aperture (NA) of the objective used. 
    200,... % radius used to performe tracking, all particles inside this radius will be considered the same particle. (nanometer)
    1.07,... %maximum value of Astigmatism for a localization to be considered valid. 
    0.57,... %minimum value of Astigmatism for a localization to be considered valid.
    288,...  %maximum value of FWHM for a localization to be considered valid. (namometer) 
    154,...  %minimum value of FWHM for a localization to be considered valid. (namometer) 
    600,...  %minimum value of Intensity for a localization to be considered valid. (A/D counts) 
    3,...    %minimum value of Signal to Noise Ration for a localization to be considered valid.  
    1,...    %maximum frame gap to be closed during particle tracking. (frame) 
    2,...    %minimum track size for a particle to be considered long track.(frame) 
    10,...   %initial frame to be analyzed. If omitted from input, Default is the first frame in the tif file.  
    100);    %final frame to be analyzed. If omitted from input, Default is the last frame in the tif file. 
%To analyze all frames in the TIF file the last two inputs should not be
%used. 

%% RUN MSD and diffusion calculation.

difusion( fileName, ... %fileName used to save results from SPTAna
    numMinTrackSteps,... %numMinTrackSteps: minimum numbers of points in a trajectory to be used for MSD calculation Summary of this function goes here
    STD_r_min);     %STD_r_min: minimum displacement for a particle to be considered.
