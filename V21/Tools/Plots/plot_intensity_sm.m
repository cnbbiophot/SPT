function plot_intensity_sm(fileName)

warning('off','MATLAB:load:variableNotFound');

load(fileName, 'Input','ParticleData_MinTrack');
if ParticleData_MinTrack.numParticlesMinTrack==0
   fprintf('No molecule to analyze that stays for %2d frames for file %s.\n', Input.LongTrackSize,fileName);
    return
end

load(fileName, 'moleculeLongTrack');
if exist('moleculeLongTrack','var')
    nParticles=(numel(moleculeLongTrack));
else
    transformData_Struct_to_Cell( fileName );
    load(fileName, 'moleculeLongTrack');
    nParticles=(numel(moleculeLongTrack));

end
    

if nParticles==0
    fprintf('No molecule to analyze with frame threshold of %2d frames.\n', Input.LongTrackSize);
    return
end


n=1;
nParticles=numel(moleculeLongTrack);
fprintf('Total number of particles: %d.\n', nParticles);

particle_data=moleculeLongTrack;
load(fileName, 'particleNoZeros');
if exist('particleNoZeros','var')
else
    particleNoZeros=zero_remover(particle_data,fileName);
end

while n ~= 0
    prompt = 'Choose a particle number to plot data (0 to finish):';
    particle_number= input(prompt);
    n=particle_number;
    if n==0
        continue;
    elseif n>nParticles
        fprintf(['No particle for this number! \n Choose a number smaller than ' num2str(nParticles) '. \n']);
    else
        minI=round(min((particleNoZeros{n,1}(:,6))));
        maxI_rap=round(max(particleNoZeros{n,1}(:,6)));
        maxI_im=round(max(particleNoZeros{n,1}(:,6)));
        maxI=max([maxI_im,maxI_rap]);
        meanI=round(mean((particleNoZeros{n,1}(:,6))));
        stdI=round(std((particleNoZeros{n,1}(:,6))));
        tinitial=min(particleNoZeros{n,1}(:,3));
        tfinal=max(particleNoZeros{n,1}(:,3));
        deltat=tfinal-tinitial+Input.dT;
        deltafr=max(particleNoZeros{n,1}(:,1))-min(particleNoZeros{n,1}(:,1))+1;
        meanBck=round(mean((particleNoZeros{n,1}(:,9))));
        
        fig=figure('Name',['Particle %s' num2str(n) '.' num2str(Input.LongTrackSize) ' frames.'], 'Position', [10 10 1080 920],'NumberTitle','off');
        set(fig, 'PaperPositionMode', 'auto');
        box('on');
        hold('all');
        plot((particle_data{n,1}(:,3)/1000),(particle_data{n,1}(:,6)),'LineWidth',3,'Color','b')
        hold('all');
        plot((particle_data{n,1}(:,3)/1000),particle_data{n,1}(:,9),'LineWidth',3,'Color','g')
        hold('all');
        xlim([ (tinitial/1000)-0.5 (tfinal/1000)+1]);
        ylim([0 maxI+2000]);
        xlabel('Time (s)','FontSize',20);
        ylabel('Intensity (A/D Counts)','FontSize',20);
        title(['Intensity vs time for particle ' num2str(n)],'FontSize',20);
        dim = [.2 .6 .3 .3];
        str = sprintf(' Max Intensity=%.0f \n Min Intensity:%.0f \n Mean Intensity:%.0f(%.0f) \n DeltaT ON = %.0f ms (%.0f frames) \n Mean rapidStorm Bckground = %.f ',maxI,minI,meanI,stdI,deltat,deltafr,meanBck);
        annotation('textbox',dim,'String',str,'FitBoxToText','on','FontSize',20);
        filename = sprintf('plot_intensity_mol_%sfr_%s.jpg',num2str(deltafr),num2str(n));
        saveas(fig,filename)
        filename = sprintf('plot_intensity_mol_%sfr_%s.fig',num2str(deltafr),num2str(n));
        saveas(fig,filename)
    end
    
    
end
close all

end





