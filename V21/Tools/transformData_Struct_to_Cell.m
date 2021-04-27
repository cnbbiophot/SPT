function [ moleculeLongTrack ] = transformData_Struct_to_Cell( fileName )
%Transforms data from structure to cell to be used in the old tools of
%version 20. 
%   

load(fileName, 'ParticleData_MinTrack','Input','ImageStr');


frames=ImageStr.NumberImages;
moleculeLongTrack=cell(ParticleData_MinTrack.numParticlesMinTrack,1);

for i=1:ParticleData_MinTrack.numParticlesMinTrack;
    moleculeLongTrack{i,1}=zeros(frames,11);
    moleculeLongTrack{i,1}(:,1)=1:1:frames; %frames number
    moleculeLongTrack{i,1}(:,3)= (moleculeLongTrack{i,1}(:,1)-1)*Input.dT; % frame time considering the exposure and reading time
    m=1;
    for n=1:frames
        if ismember(n,ParticleData_MinTrack.frames{i,1})
            moleculeLongTrack{i,1}(n,4:5)=ParticleData_MinTrack.coords{i,1}(m,1:2);
            moleculeLongTrack{i,1}(n,6)=ParticleData_MinTrack.intensity{i,1}(m,1);
            moleculeLongTrack{i,1}(n,7:8)=ParticleData_MinTrack.fwhm{i,1}(m,1:2);
            moleculeLongTrack{i,1}(n,9)=ParticleData_MinTrack.Back{i,1}(m,1);
            moleculeLongTrack{i,1}(n,7:8)=ParticleData_MinTrack.fwhm{i,1}(m,1:2);
            moleculeLongTrack{i,1}(n,11)=ParticleData_MinTrack.SNR{i,1}(m,1);
            m=m+1;
        end
    end
end

save (fileName,'moleculeLongTrack','-v7.3','-append')


end

