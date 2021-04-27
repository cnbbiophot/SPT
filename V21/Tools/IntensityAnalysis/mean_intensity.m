function [ intensityMean ] = mean_intensity(fileName,plotON)

%Calculates the mean intensity for every particle


%Created by: CVS
%On August 10/2018

load(fileName,'Input','ParticleData_MinTrack');

if ParticleData_MinTrack.numParticlesMinTrack==0
   fprintf('No molecule to analyze.');
    return
end
q=matfile(fileName);
 varIsInMat = @(name) ~isempty(who(q, name));
 checkMoleculeLong = varIsInMat('moleculeLongTrack');
 if checkMoleculeLong==1;
     load(fileName, 'moleculeLongTrack');
     particleData=moleculeLongTrack;
 elseif checkMoleculeLong==0
     transformData_Struct_to_Cell( fileName );
     load(fileName, 'moleculeLongTrack');
     particleData=moleculeLongTrack;
 end

nParticles=size(particleData,1);

if nParticles==0
    fprintf('No molecule to analyze.');
    return
end

intensityMean=zeros(nParticles,3);

for p=1:nParticles
    [ii,~,v]=find(particleData{p,1}(:,6));
    intensityMean(p,1)=mean(v);
    intensityMean(p,2)=std(v);
    intensityMean(p,3)=p;
end

if plotON==1
fig=figure('Name','Intensity ','NumberTitle','off','Position', [10 10 1800 1200]);
set(fig, 'PaperPositionMode', 'auto');
axes1 = axes('Parent',fig,'FontSize',20);
box(axes1,'on');
hold(axes1,'all');
bins1=(0:100:40000);
histo1=histf(nonzeros(intensityMean(:,1)),bins1,'facecolor','b', 'facealpha',.5,'edgecolor','b');
hold on
title(['Intensity for all molecules with long trajectories.'],'FontSize',20)
xlabel('Intensity (A/D Counts)','FontSize',20);
ylabel('counts','FontSize',20);
xlim(axes1,[-10 3500])
filename = sprintf('plot_Intensity.jpg', fileSave); 
saveas(fig,filename)
filename = sprintf('plot_Intensity.fig',fileSave); 
saveas(fig,filename)
hold off
end
end
  