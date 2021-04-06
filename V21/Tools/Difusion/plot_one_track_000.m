function [trajectory] = plot_one_track_000 (fileName,tracknumber,numMinTrackSteps)
%% Plot track
% Plots one track in a grid with the size of the pixel
%2019.06.20 - CVS - Change graphic axis to match image size

load(fileName, 'ParticleData','Input','ImageStr');

filesave=Input.Save;
imSizeX=ImageStr.imageInfo(1,1).Width;
imSizeY=ImageStr.imageInfo(1,1).Height;
pixelSize=Input.PixelSize;

idx_valid=ParticleData.numFrames>(numMinTrackSteps-1);
ParticleDataIdx.minTrack = particle_idx_after(ParticleData,numMinTrackSteps,idx_valid,Input);

moleculeLongTrackDataArray=ParticleDataIdx.minTrack;

molecule=moleculeLongTrackDataArray.coords{tracknumber,1}(:,:);
frames=numel((moleculeLongTrackDataArray.frames{tracknumber,1}(:,1)));


figure1=figure('Name',['trajectory for ' num2str(frames) ' frames for molecule ' num2str(tracknumber) ],'NumberTitle','off','Position',[10 10 1800 1200]);
% figure1=figure('Name',['trajectory for ' num2str(frames) ' frames for molecule ' num2str(tracknumber) ]);

% fig=gca;
% hold all


% fr=1;
% while fr<=frames
%     if (molecule(fr,4)==0&&molecule(fr,5)==0)
%         molecule(fr,:)=[];
%         frames=frames-1;
%     else
%         fr=fr+1;
%     end
% end

Xmin=((min(molecule(:,1))));
Ymin=(min(molecule(:,2)));
molecule(:,1)=molecule(:,1)-Xmin;
molecule(:,2)=molecule(:,2)-Ymin;

for i_step = 1 : frames
    if i_step==1
        molecule_ini=(molecule(i_step,:));   
    elseif i_step==frames
        molecule_end=(molecule(i_step,:));   
    end
end

plot_track_nice(molecule(:,1), molecule(:,2),molecule_ini(:,1),molecule_ini(:,2),molecule_end(:,1),molecule_end(:,2),figure1)
fig=gca;

%Xmax=((max(molecule(:,4)))+100);
%Ymax=((max(molecule(:,5)))+100);
%axis([-10 Xmax+10  -10 Ymax+10]);

%title(['Trajectory for ' num2str(frames) ' frames for molecule ' num2str(tracknumber) '.' ]);
%stdx=round(std(molecule(:,4)));
%stdy=round(std(molecule(:,5)));
%xt=[Xmax-50];
%yt=[Ymax-50];
%str={['STDx =' num2str(stdx) 'nm STDy =' num2str(stdy) 'nm' ]};
%text(xt,yt,str,'HorizontalAlignment','center','FontSize',15);


trajectory=molecule;

filename = sprintf('%s_trajectory_moelcule_%s.png',filesave,num2str(tracknumber));
saveas(fig,filename)
filename = sprintf('%s_trajectory_moelcule_%s.fig',filesave,num2str(tracknumber));
saveas(fig,filename)
filename = sprintf('%s_trajectory_moelcule_%s.eps',filesave,num2str(tracknumber));
saveas(fig,filename)
end

