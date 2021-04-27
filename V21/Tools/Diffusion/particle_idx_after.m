function [ ParticleDataIdx ] = particle_idx_after( ParticleData,LongTrackSize,validParticles,Input)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

ParticleDataIdx=struct;

ParticleDataIdx.numFrames=ParticleData.numFrames(validParticles);
ParticleDataIdx.frames=ParticleData.frames(validParticles);
ParticleDataIdx.time=ParticleData.time(validParticles);
ParticleDataIdx.coords=ParticleData.coords(validParticles);
ParticleDataIdx.intensity=ParticleData.intensity(validParticles);
ParticleDataIdx.fwhm=ParticleData.fwhm(validParticles);
ParticleDataIdx.SNR=ParticleData.SNR(validParticles);
ParticleDataIdx.Back=ParticleData.Back(validParticles);
ParticleDataIdx.numParticlesMinTrack=numel(ParticleDataIdx.numFrames(:,1));
if ParticleDataIdx.numParticlesMinTrack==0
    return
end
ParticleDataIdx.numLocalization=sum(ParticleDataIdx.numFrames(:,1));
localisation=1;


for particle=1:ParticleDataIdx.numParticlesMinTrack
        numLocalisations=ParticleDataIdx.numFrames(particle,1);
        FWHM_row(localisation:localisation+numLocalisations-1,1)=ParticleDataIdx.fwhm{particle}(:,1);
        FWHM_row(localisation:localisation+numLocalisations-1,2)=ParticleDataIdx.fwhm{particle}(:,2);
        Int_row(localisation:localisation+numLocalisations-1,1)=ParticleDataIdx.intensity{particle}(:,1);
        Back_row(localisation:localisation+numLocalisations-1,1)=ParticleDataIdx.Back{particle}(:,1);      
        Astig_row(localisation:localisation+numLocalisations-1,1)=ParticleDataIdx.fwhm{particle}(:,3);      
        SNR_row(localisation:localisation+numLocalisations-1,1)=ParticleDataIdx.SNR{particle}(:,1);      
        localisation=localisation+numLocalisations;
end


ParticleDataIdx.FWHMmean=mean(FWHM_row(:));
ParticleDataIdx.FWHMstd=std(FWHM_row(:));
ParticleDataIdx.Intmean=mean(Int_row);
ParticleDataIdx.Intstd=std(Int_row);
ParticleDataIdx.Astigmean=mean(Astig_row);
ParticleDataIdx.Astigstd=std(Astig_row);
ParticleDataIdx.SNRmean=mean(SNR_row);
ParticleDataIdx.SNRstd=std(SNR_row);
ParticleDataIdx.Backmean=mean(Back_row);
ParticleDataIdx.Backstd=std(Back_row);


clear FWHM_row Int_row Astig_row SNR_row Back_row 

end

