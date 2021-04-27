function [trajectories] = plot_tracks (fileName)

%% Plot tracks
% We want to plot eahc track in a given color. Normally we would have to
% retrieve the points coordinates in the given |points| initiall cell
% arrat, for each point in frame. To skip this, we simple use the
% adjacency_tracks, that can pick points directly in the concatenated
% points array |all_points|.
%2019.06.20 - CVS - Change graphic axis to match image size 
%2021.01.25 - CVS - Change to run with anaSPT v21

load(fileName, 'ParticleData_MinTrack','Input','ImageStr');

moleculeTrackDataArray=ParticleData_MinTrack;
filesave=Input.Save;
imSizeX=ImageStr.imageInfo(1,1).Width;
imSizeY=ImageStr.imageInfo(1,1).Height;
pixelSize=Input.PixelSize;

n_tracks = moleculeTrackDataArray.numParticlesMinTrack;
colors = hsv(n_tracks);
trajectories=cell(1,n_tracks);
Xmax=(imSizeX*pixelSize)/1000;
Ymax=(imSizeY*pixelSize)/1000;


fig=figure('Name',['trajectory for ' num2str(n_tracks) ' particles'],'NumberTitle','off','Position', [10 10 1800 1200]);
set(fig, 'PaperPositionMode', 'auto');
axes1 = axes('Parent',fig,'FontSize',20);
box(axes1,'on');
hold(axes1,'all');
axis([0 Xmax  0 Ymax]);


for i_track = 1 : n_tracks
    molecule=moleculeTrackDataArray.coords{i_track,1}(:,:);
    frames=numel(molecule(:,1));
    fr=1;
    while fr<=frames
        if (molecule(fr,1)==0&&molecule(fr,2)==0)
            molecule(fr,:)=[];
            frames=frames-1;
        else
            fr=fr+1;            
        end
    end
    plot(molecule(:,1)/1000, molecule(:,2)/1000, 'Color', colors(i_track, :),'LineWidth',4)
%     text(molecule(1,4)/1000,molecule(1,5)/1000,num2str(i_track),'FontSize',11);
    title(['Trajectories for ' num2str(n_tracks) ' particles.']);
    trajectories{1,i_track}=molecule;
    hold on
   
   
end

xlabel('Position x (\mum)','FontSize',20);
ylabel('Position y (\mum)','FontSize',20);
set(gca,'YDir','reverse');
axis image
 

filename = sprintf('%splot_trajectory_%smolecules.jpg', filesave,num2str(n_tracks)); 
saveas(fig,filename)
filename = sprintf('%splot_trajectory_%smolecules.fig', filesave,num2str(n_tracks)); 
saveas(fig,filename)

end

