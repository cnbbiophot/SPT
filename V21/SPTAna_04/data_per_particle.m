function [ParticleData] = data_per_particle(Input, DataFilter, Tracks) 
%separates the parameters for each particles in the image

%% INPUT:
%coordArray:cell array where each cell has the all the positions x and y for all
%localizations in that frame
%int= a cell array with all intensity for all particles on every frame
%frames=total number of frames
%psf: cell array where each cell has the all the PSF x and PSF y for all
%localizations in that frame
%bg: localisation background array
%timeBetweenFrames: time between frames used for the experiment (exposuretime (ms) + readout time (ms)). In ms
%tracks: a cell array, with one cell per found
%track. Each track is made of a |n_frames x 1| integer array, containing
%the index of the particle belonging to that track in the corresponding frame. 
% NaN values report that for this track at this frame, a particle
%could not be found (gap).

%% OUTPUT:
%particle_data: a cell array with |number of molecules x 1| where cells have the data for a molecule in every frame
% where the columns are:
%frame number : time in ms : position x (nm) : position y in nm:intensity (ADC): PSF x (nm): PSF y (nm): background

%nfram_part: number of frames a molecule is present.


%% Created by: CVS
%On July 04/2018
%Edited by CVS July 13/2018
%Edited by CVS July 21/2018 - Fix distance between no consecutive frames
%Edited by CVS April 2020 - Transform particle data into Struct and also
%only save data for when particle is ON. 

%% 
numTrack=size(Tracks.tracks,1);
ParticleData=struct;
ParticleData.numFrames=zeros(numTrack,1);

%% 

for idxTrack=1:numTrack
    ParticleData.numFrames(idxTrack)=sum(not(isnan(Tracks.tracks{idxTrack})));
    numFrames=ParticleData.numFrames(idxTrack);
    idxFrame=find(not(isnan(Tracks.tracks{idxTrack}))); % Da el frame en el que hay partículas
    ParticleData.frames{idxTrack,1}(:,1)=idxFrame:1:(idxFrame+numFrames-1);
    ParticleData.time{idxTrack,1}(:,1)=(ParticleData.frames{idxTrack,1}(:,1)-1).*Input.dT;
    idxPartFrame=Tracks.tracks{idxTrack}(idxFrame); %Da la partícula de idxTrack que está en el frame idxFrame
    for frame=1:numel(idxFrame)
        ParticleData.coords{idxTrack,1}(frame,1:2)=DataFilter.coord{idxFrame(frame),1}(idxPartFrame(frame),1:2);
        ParticleData.intensity{idxTrack,1}(frame,1)=DataFilter.int{idxFrame(frame),1}(idxPartFrame(frame));
        ParticleData.fwhm{idxTrack,1}(frame,1:2)=DataFilter.FWHM{idxFrame(frame),1}(idxPartFrame(frame),1:2);
        ParticleData.fwhm{idxTrack,1}(frame,3)=DataFilter.Astig{idxFrame(frame),1}(idxPartFrame(frame),1);
        ParticleData.SNR{idxTrack,1}(frame,1)=DataFilter.SNR{idxFrame(frame),1}(idxPartFrame(frame));
        ParticleData.Back{idxTrack,1}(frame,1)=DataFilter.backg{idxFrame(frame),1}(idxPartFrame(frame));
    end
end





