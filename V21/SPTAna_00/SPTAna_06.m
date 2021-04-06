function ParticleData=SPTAna_06(ParticleData, numMinTrackSteps)
% Filtering out all tracks that are shorter than numMinTrackSteps steps

%tracksDataLongArray contiene los datos de los tracks moleculares más largos que numMinTrackSteps
% El formato es el de tracksData

ParticleData.idxTracksLongerMinTrackSteps=ParticleData.numFrames>(numMinTrackSteps-1);

