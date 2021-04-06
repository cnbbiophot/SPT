function ParticleDataIdx=SPTAna_05(ParticleData,Input)
% Filtering out all tracks that are shorter than numMinTrackSteps steps

%tracksDataLongArray contiene los datos de los tracks moleculares más largos que numMinTrackSteps
% El formato es el de tracksData

fprintf(Input.fileID,'\nStep 5 - Long tracks selection.\n');

fprintf(Input.fileID,'\n      Particles  |      Number     |  Localizations  |  FWHM (nm)  |  Astigmatism  |   Intensity   |   Background  |   SNR    | ' );
fprintf(Input.fileID,'\n      tracks  >= |  of Particles   |  (%% of total)   |             |               |  (A/D Counts) |               |          | ' );
fprintf(Input.fileID,'\n    -------------|-----------------|-----------------|-------------|---------------|---------------|---------------|----------| ' );

numMinTrackSteps=Input.LongTrackSize;

idx_all=ParticleData.numFrames>(0);
ParticleData = particle_idx( ParticleData,0,idx_all,Input);


% Tracks with Minimum number of frames as set in the input by LongTrackSize

ParticleData.idxTracksLongerMinTrackSteps=ParticleData.numFrames>(numMinTrackSteps-1);
ParticleDataIdx = particle_idx( ParticleData,numMinTrackSteps,ParticleData.idxTracksLongerMinTrackSteps,Input);

% Analyzes of longer tracks
for n=1:10
    idx_valid=ParticleData.numFrames>(numMinTrackSteps-1+n);
    fieldname = sprintf('MinTrack_%s',num2str(numMinTrackSteps+n));
    ParticleDataIdx.(fieldname)= struct;
    ParticleDataIdx.(fieldname) = particle_idx(ParticleData,numMinTrackSteps+n,idx_valid,Input);
end

fprintf(Input.fileID,'\n\n         Long tracks selection - Done.\n');

end


