function SPTAna_gui(Input)

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
%initialFrame: initial frame to be analyzed. If omitted from input, Default is the first frame in the tif file.  
%finalFrame: final frame to be analyzed. If omitted from input, Default is the last frame in the tif file. 
    %To analyze all frames in the TIF file the last two inputs should not be
    %used. 

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
%% Step 1 - Creating output for .mat file, Saving INPUTS into struct and LOADING data:

% Input=struct;
% Input.Save=filesave;
% Input.ImageName=fname;
% Input.Localizations=filecoords;
% Input.Counts=filecounts;
% Input.PixelSize=pixel;
% Input.dT=timeinterval;
% Input.Lambda=lambda;
% Input.NA=numericalAperture;
% Input.LocalizationRadius=localizationStd;
% Input.Save=sprintf('%s.mat',filesave);
% Input.Astgmax=Astgmax;
% Input.Astgmin=Astgmin;
% Input.FWHMmax=FWHMmax;
% Input.FWHMmin=FWHMmin;
% Input.Intmin=Intmin;
% Input.SNRmin=SNRmin;
% Input.MaxGapClosing=MaxGapClosing;
% Input.LongTrackSize=LongTrackSize;
% 
% % Check if input contain an initial and/or a final frame to be analyzed:
% if nargin<20
%      Input.finalFrame=-1;
%      Input.initialFrame=0;
% elseif nargin<21
%      Input.finalFrame=-1;
% elseif nargin==20
%      Input.finalFrame=finalFrame;
%      Input.initialFrame=initialFrame;
% end

save(Input.Save,'Input');

% Creating output file and start counting time:

filenameout = sprintf('%s_output.txt',Input.Save);
Input.fileID = fopen(filenameout,'w');
fprintf(Input.fileID,'\nSPT Program v.21 - 2020.05.18.');
t1 = datestr(now,'mmmm dd, yyyy HH:MM:SS AM');
fprintf(Input.fileID,'\n%s',t1);
t1n=now;

% Loading Raw Data

[ImageStr,InputData,Input] = SPTAna_01(Input); 

Input.numFrames=ImageStr.nframes;

save(Input.Save,'Input','-append');

%% Step 2 - Preparing Data 

[TheoreticalData,InputData,DataPerFrame] =SPTAna_02(Input,InputData);
save(Input.Save,'InputData','TheoreticalData','-append');


%% Step 3 - Filtering Localizations to remove noise

[DataFilterAstg,DataFilterFWHM,DataFilterInt,DataFilterSNR] = SPTAna_03(Input,DataPerFrame); % removes from the PSF the values that are bigger than 2 x the Rayleigh resolution
save(Input.Save,'DataFilterAstg','DataFilterFWHM','DataFilterInt','DataFilterSNR','-append');

DataFilter=DataFilterSNR;

%% Step 4 - Tracking Particles   

[ ParticleData, Tracks] = SPTAna_04(Input,DataFilter);
save(Input.Save,'Tracks', 'ParticleData', '-append');


%% Step 5 - Long track Particle Selection  

 ParticleData_MinTrack=SPTAna_05(ParticleData, Input);
 save(Input.Save, 'ParticleData_MinTrack', '-append');


fprintf(Input.fileID,'\nFinished!.\n');

t2 = datestr(now,'mmmm dd, yyyy HH:MM:SS AM');
fprintf(Input.fileID,'\n%s',t2);
t2n=now;

time_diff = t2n - t1n;
dt2=datestr(time_diff,13);
fprintf(Input.fileID,'\n Total Elapsed time: %s',dt2);


fclose(Input.fileID);


% fprintf(fileID,'\nNumber of molecules that stays more than %3d frames fluorescent: %3d\n', numMinTrackSteps, numel(moleculeLongTrackDataArray));
% 
% fprintf(fileID,'\nParticles per frame');
% [ countFiltered  ] = anaSPT_08(moleculeLongTrackDataArray, numLocalisationsFrame, numFrames);
% meanLocalizationPerFrame=sum(nonzeros(countFiltered(:,3)))/numFrames;
% 
% fprintf(fileID,'\n     Mean number of particles long track per frame: %3.2f\n', meanLocalizationPerFrame);
% 
% save (fileSave,version,'-append')
% 
% 
% %%
% % Recover the cell array of the coordenates per frame to calculate the RDF
% %after applying the filters. 
% % fprintf(fileID,'\nRecovering coordenates vector per frame with only the relevant particles.');
% % [ coordFinalFiltered, psfFinalFiltered ] = recover_coordenate_per_frame( moleculeTrackDataArray );
% 
% 
% 
% %%
% % %% RDF calculation
% %Need to reconsider the calculation of the RDF to eliminate localization
% %that are superimposed.
% 
% % fprintf(fileID,'\nPerforming RDF calculations.');
% % 
% % [distM,grall,coordsfout,data] = radial_2D_all_frames(coordFinalFiltered,imSizeX,imSizeY,pixelSize,numFrames,20);
% % 
% % coordFinal=coordsfout;
% % fprintf(fileID,'\nMean distance between particles: %3.0f ± %3.0f nm.\n', data.mdistnm,data.devnm);
% % fprintf(fileID,'\n     RDF calculations...Done.\n');
% 
% fprintf(fileID,'\n     Saving mat file...\n');
% version='-v7.3'; % Added because sometimes we can get the error message: 'Warning: Variable 'moleculeTrackDataArray' cannot be saved to a MAT-file whose version is older than 7.3. To save this variable, use the -v7.3 switch. Skipping... 
% save (fileSave,version,'-append')
% fprintf(fileID,'\n     Finished OK!\n');
% 
% fclose (fileID);
% 
% 
% 
% 
% 
% %%
% %%
% %%Filtering particles with PSF out of range   
% fprintf(Input.fileID,'\nStep 6 of 16 - Filtering by PSF');
% 
% if psfFilter==1
%     maxPSF=meanPSF+(psfError*meanErrorPSF); % maximum allowed value for the PSF
%     minPSF=meanPSF-(psfError*meanErrorPSF); % minimim allowed value for the PSF
%     if minPSF<pixel
%     minPSF=pixel;
%     end
% 
% 
%     fprintf(Input.fileID,'\n     Filtering Molecules that are out of the range %3.0f < PSF < %3.0f.', minPSF,maxPSF);
%     
%     [ particleDataFiltered, deleted, keep,nfram_part_new ] = psf_filter(particleData,meanPSF,meanErrorPSF,psfError,nfram_part);
%     
%     filename = sprintf('%s06_particleData',filesave);  
%     assignin('base',filename,particleDataFiltered); 
% 
%     filename = sprintf('%s06_numFrameperMolecule',filesave);  
%     assignin('base',filename,nfram_part_new);  
%     
%     fprintf(Input.fileID,'\n     Molecules removed: %3.0f...', (deleted));
%     fprintf(Input.fileID,'\n     Molecules kept: %3.0f...', (keep));
%     fprintf(Input.fileID,'\n     Mean number of Molecules removed on each frame %3.1f.', (deleted./nframes));
%     
%     particleData=particleDataFiltered;
%     
%     
% end
% 
% if keep==0;
%     return
% end
% %% Removing zero lines from particleData vector
% 
% [ particleNoZero ] = zero_remover(particleData);
% particleData=particleNoZero;
% filename = sprintf('%s06_particleNoZero',filesave);  
% assignin('base',filename,particleNoZero);
% %%
% fprintf(Input.fileID,'\nStep 7 of 17 - Filtering by Minimum number of frames');
% %%%% Filtering Particles that appear in less than 0.5% frames
% 
% if frameFilter==1
%     outnumber=0.005*nframes; % removes molecules that appears in only 0.5% of the frames
%     if outnumber<3
%         outnumber=3;
%     end
% 
%     fprintf(Input.fileID,'\n     Filtering molecules that appear only in %2.0f frame(s).', outnumber);
% 
%    [ particleDataFiltered, deleted, keep, nfram_part_new ] = frame_filter(particleData,outnumber,nfram_part);
% 
%     filename = sprintf('%s07_particleData',filesave);  
%     assignin('base',filename,particleDataFiltered); 
% 
%     filename = sprintf('%s07_numFramePerMolecule',filesave);  
%     assignin('base',filename,nfram_part_new);   
% 
%     fprintf(Input.fileID,'\n     Molecules removed: %3.0f...', (deleted));
%     fprintf(Input.fileID,'\n     Molecules kept: %3.0f...', (keep));
%     fprintf(Input.fileID,'\n     Mean number of Molecules removed on each frame %3.1f.', (deleted./nframes));
%     
%     particleData=particleDataFiltered;
%  
%     
% end
% %%
% %%Calculating Mean value for the coordenates of each particle
% 
% fprintf(Input.fileID,'\nStep 8 of 17 - Mean Coordenates');
% 
% fprintf(Input.fileID,'\n     Calculating Mean Coordenates for each molecule.');
% [ coordMean,fitCoord,sigmax,sigmay ] = mean_coordenates(particleData);
% stdLocationx=mean(coordMean(:,2));
% 
% filename = sprintf('%s08_coordMean',filesave);  
% assignin('base',filename,coordMean); 
% filename = sprintf('%s08_sigmaPosX',filesave);  
% assignin('base',filename,sigmax);
% filename = sprintf('%s08_sigmaPosY',filesave);  
% assignin('base',filename,sigmay);
% 
% % h_coordMeanx=hist_distrib(coordMean,1,NumOfBins,50);
% % h_coordStdx=hist_distrib(coordMean,2,NumOfBins,50);
% 
% stdLocationy=mean(coordMean(:,4));
% % h_coordMeany=hist_distrib(coordMean,3,NumOfBins,50);
% % h_coordStdY=hist_distrib(coordMean,4,NumOfBins,50);
% 
% % hcoordMeanx=transpose(vertcat(h_coordMeanx.values,h_coordMeanx.histo));
% % hcoordMeany=transpose(vertcat(h_coordMeany.values,h_coordMeany.histo));
% fprintf(Input.fileID,'\n     Standard Deviation in x is %3.1f and in y is %3.1f.',stdLocationx,stdLocationy);
% filename = sprintf('%s08_meanCoord.txt',filesave);  
% save(filename, 'coordMean', '-ascii');
% % save('meanCoord_histx.txt', 'hcoordMeanx', '-ascii');
% % save('meanCoord_histy.txt', 'hcoordMeany', '-ascii');
% 
% 
% 
% %%
% %% Calculating number of particles per frame after filtering. 
% fprintf(Input.fileID,'\nStep 9 of 17 - Particles per frame');
% 
% if (psfFilter==1||frameFilter==1)
%      fprintf(Input.fileID,'\n     Counting molecules per frame after filtering');
%     [ countFiltered  ] = particle_per_frame(particleData,countsIn,nframes);
%     countsFinal=countFiltered;
% end
% 
% filename = sprintf('%s09_countFiltered',filesave);  
% assignin('base',filename,countFiltered); 
% 
% 
% 
% %%
% %%Calculating the average displacement of one particle between two frames
% 
% fprintf(Input.fileID,'\nStep 10 of 17 - Average Displacement');
% 
% fprintf(Input.fileID,'\n     Calculating average displacement per molecule after filtering');
%  
% [ particleData, averageDispl ] = average_displacement_per_frame(particleData);
% 
% filename = sprintf('%s10_averageDisplacement',filesave);  
% assignin('base',filename,averageDispl); 
% filename = sprintf('%s10_particleData',filesave);  
% assignin('base',filename,particleData); 
% 
% 
% %%
% 
% %%Calculating the intensity directly from the image
% 
% 
% fprintf(Input.fileID,'\nStep 11 of 17 - Calculating intensity from raw image');
% [ particleData ] = intensity_in_image(particleData,imageSeq,psfMean,pixel);
% 
% filename = sprintf('%s11_particleData',filesave);  
% assignin('base',filename,particleData); 
% 
% 
% 
% 
% %%
% % Normalizing Intensity
% 
% fprintf(Input.fileID,'\nStep 12 of 17 - Normalizing Intensity by average and to 1');
% [ intensityMean ] = mean_intensity(particleData);
% [ particleData ] = intensity_normalize(particleData, intensityMean);
% 
% filename = sprintf('%s12_particleData',filesave);  
% assignin('base',filename,particleData); 
% filename = sprintf('%s12_intensityMean',filesave);  
% assignin('base',filename,intensityMean); 
% filename = sprintf('%s12_intensityMean.txt',filesave);
% save(filename, 'intensityMean', '-ascii');
% 
% 
% 
% 
% 
% %%
% % Recover the cell array of the coordenates per frame to calculate the RDF
% %after applying the filters. 
% fprintf(Input.fileID,'\nStep 13 of 17 - Recovering coordenates vector per fram with only the relevant molecules');
% [ coordFinalFiltered, psfFinalFiltered ] = recover_coordenate_per_frame( particleData );
% 
% filename = sprintf('%s13_coordFinalFiltered',filesave);  
% assignin('base',filename,coordFinalFiltered); 
% filename = sprintf('%s13_psfFinalFiltered',filesave);  
% assignin('base',filename,psfFinalFiltered); 
% 
% 
% 
% %%
% %%%
% %%Analyzing PSF after filtering
% 
% fprintf(Input.fileID,'\nStep 14 of 17 - PSF analysis after filtering...');
% 
% psfToAnalyze=psfFinalFiltered;
% [ psfMean, meanpsfx, meanpsfy, stdpsfx, stdpsfy  ] = psf_analysis(psfToAnalyze);
% 
% fprintf(Input.fileID,'\n     For all molecules after filtering mean experimental PSF is %3.1f  in x and %3.1f  in y.',meanpsfx,meanpsfy);
% filename = sprintf('%s14_psfMean',filesave);  
% assignin('base',filename,psfMean);
% filename = sprintf('%s14_meanpsfx',filesave);  
% assignin('base',filename,meanpsfx);
% filename = sprintf('%s14_meanpsfy',filesave);  
% assignin('base',filename,meanpsfy);
% filename = sprintf('%s14_stdpsfx',filesave);  
% assignin('base',filename,stdpsfx);
% filename = sprintf('%s14_stdpsfy',filesave);  
% assignin('base',filename,stdpsfy);
% 
% filename = sprintf('%s14_psfMean.txt',filesave); 
% save(filename, 'psfMean', '-ascii');
% 
% 
% 
% 
% %%
% % %% RDF calculation
% %Need to reconsider the calculation of the RDF to eliminate localization
% %that are superimposed.
% 
% fprintf(Input.fileID,'\nStep 15 of 17 - Performing RDF calculations.');
% 
% [distM,grall,coordsfout,data] = radial_2D_all_frames(coordFinalFiltered,Lx,Ly,pixel,nframes,NumOfBins);
% 
% coordFinal=coordsfout;
% 
% filename = sprintf('%s15_distM',filesave);  
% assignin('base',filename,distM);
% filename = sprintf('%s15_grall',filesave);  
% assignin('base',filename,grall);
% filename = sprintf('%s15_coordFinal',filesave);  
% assignin('base',filename,coordFinal);
% filename = sprintf('%s14_data',filesave);  
% assignin('base',filename,data);
% 
% 
% fprintf(Input.fileID,'\n     RDF calculations...Done.\n');
% 
% %%
% %Calculating delta t that the molecule stays fluorescent
% 
% fprintf(Input.fileID,'\nStep 16 of 17 - Calculating deltaT and average intensity and its histogram.');
% 
% [deltaTFluo,deltaTFluoAll]=deltTFluorescent(particleData,outnumber);
% [blink] = blinking(deltaTFluo);
% 
% 
% filename = sprintf('%s16_deltaTFluo',filesave);  
% assignin('base',filename,deltaTFluo);
% filename = sprintf('%s16_deltaTFluoAll',filesave);  
% assignin('base',filename,deltaTFluoAll);
% filename = sprintf('%s15_blinking',filesave);  
% assignin('base',filename,blink);
% 
% if size(deltaTFluoAll,1)>2
%     h_time=hist_distrib(deltaTFluoAll,6,NumOfBins,timeinterval);
%     h_intens=hist_distrib(deltaTFluoAll,7,NumOfBins,100);
%     htime=transpose(vertcat(h_time.values,h_time.histo));
%     hinten=transpose(vertcat(h_intens.values,h_intens.histo));
% else
%     fprintf(Input.fileID,'\n     No relevant fluorescent time was found for this experiment.');
%     h_time=0;
%     h_intens=0;
%     htime=0;
%     hinten=0;
%     
% end
% 
% filename = sprintf('%s16_htime.txt',filesave);  
% save(filename, 'htime', '-ascii');
% filename = sprintf('%s16_hinten.txt',filesave); 
% save(filename, 'hinten', '-ascii');
% filename = sprintf('%s16_htime',filesave);  
% assignin('base',filename,h_time);
% filename = sprintf('%s16_hintens',filesave);  
% assignin('base',filename,h_intens);
% 
% %% Plot Trajectory
% fprintf(Input.fileID,'\nStep 17 of 17 - Plotting and printting trajectories.');
% 
% [trajectories] = plot_tracks (filesave,particleData);
% 
% filename = sprintf('%s17_trajectory',filesave);  
% assignin('base',filename,trajectories);
% 
% %% MSD calculation
% 
% [ tracks ] = transform_tracks(trajectories);
% SpaceUnits='um';
% TimeUnits='s';
% [ ma ] = msd(SpaceUnits,TimeUnits,tracks,nframes,timeinterval);
% 
% filename = sprintf('%s16_MSD',filesave);  
% assignin('base',filename,ma);
% 
% 

% 
