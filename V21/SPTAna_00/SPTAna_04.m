function [ ParticleData, Tracks] = SPTAna_04(Input,DataFilter)
%Identifies the same particle in all frames considering the desired localization radius. Returns a file with a cell
%were each row is a vector containing the number of the particle in each
%frame. 
%Check original: https://es.mathworks.com/matlabcentral/fileexchange/34040-simple-tracker

%% INPUT:
%Input: 

%DataFilter: 

%% OUTPUT:
%ParticleData:

%Tracks: 
%   tracks: a cell array, with one cell per found 
%       track. Each track is made of a |n_frames x 1| integer array, containing
%       the index of the particle belonging to that track in the corresponding
%       frame. NaN values report that for this track at this frame, a particle
%       could not be found (gap). 

%   adjacency_tracks: a cell array with one cell per track, but the indices in each track are the global
%       indices of the concatenated points array, that can be obtained by
%       |all_points = vertcat( points{:} );|. It is very useful for plotting
%       applications.

%   A: the sparse adjacency matrix. This matrix is made everywhere of 0s, expect for links
%       between a source particle (row) and a target particle (column) where
%       there is a 1. Rows and columns indices are for points in the concatenated
%       points array. Only forward links are reported (from a frame to a frame
%       later), so this matrix has no non-zero elements in the bottom left
%       diagonal half. Reconstructing a crude trajectory using this matrix can be
%       as simple as calling |gplot( A, vertcat( points{:} ) )|


%% Adapted by: CVS
%On July 13/2018
%Edited: April 2020

fprintf(Input.fileID,'\nStep 4 - Tracking Particles.');

if Input.MaxGapClosing<0
    Input.MaxGapClosing=Inf;
end

Tracks=struct;
Tracks.localizationUn=Input.LocalizationRadius;  % uncertainty to be considered for the particle localization in nanometers. 
fprintf(Input.fileID,'\n           Uncertainty considered for the Particle identification: %3.1f nm.', Tracks.localizationUn);
fprintf(Input.fileID,'\n           Gap-Closing for NON-Consecutives frames: %3.0f frames.', Input.MaxGapClosing);

debug = false;



[ Tracks.tracks, Tracks.adjacency_tracks, Tracks.A ] = simple_tracker(Input.fileID, DataFilter.coord,'Method','NearestNeighbor','MaxLinkingDistance', Tracks.localizationUn,'MaxGapClosing',Input.MaxGapClosing,'Debug', debug); % tracks localization from one frame to the other to identify if the belong to the same molecule.

fprintf(Input.fileID,'\n               Initial total number of Connected Localizations (Particles): %3d.', (size(Tracks.tracks,1)));

%% Tracking Intensities  

fprintf(Input.fileID,'\n           Starting Particles Identification.');

[ParticleData] = data_per_particle(Input, DataFilter, Tracks); 

fprintf(Input.fileID,'\n               Struct with the data of %3d particles was generated.', (size(ParticleData.numFrames,1)));


fprintf(Input.fileID,'\n         Tracking Particles - Done.\n');


%
end

