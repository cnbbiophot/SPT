anaSPT ('SPTana_test_old_','images.tif','Loca.txt','counts.txt', 585,1.49, 78, 500,1,6.8,10);

load('SPTana_test_old_.mat', 'numFramesParticle','fileSave','moleculeLongTrackDataArray','imSizeX', 'imSizeY', 'pixelSize','moleculeTrackDataArray','coordArray');

moleculeLongTrackDataArray=anaSPT_06(moleculeTrackDataArray, numFramesParticle, 10);

[trajectories] = plot_tracks (fileSave, moleculeLongTrackDataArray, imSizeX, imSizeY, pixelSize);
[ tracks_for_msd ] = transform_tracks(trajectories);

nparticles=size(moleculeLongTrackDataArray,1);
trajectory=cell(nparticles,1);
msd=cell(nparticles,1);
% mobile=zeros(nparticles,1);
Dfit2=zeros(nparticles,5);
for i=1:nparticles
    %trajectory{i,1}=plot_one_track_000 (moleculeLongTrackDataArray, pixelSize,i);
    steps=size(trajectories{1,i},1);
    delta_r=zeros(steps-1,1);
    for j=1:steps-1
        xi=trajectories{1,i}(j,4);
        yi=trajectories{1,i}(j,5);
        xf=trajectories{1,i}(j+1,4);
        yf=trajectories{1,i}(j+1,5);
        delta_r(j)=sqrt((xf-xi)^2+(yf-yi)^2);
    end
    Dfit2(i,3)=mean(delta_r);  %mean displacement 
    Dfit2(i,4)=std(delta_r);   %standard desviation for the displacement
%    Dfit2(i,5)=var(delta_r); %displacement variance
    if Dfit2(i,3)>=30
       mobile(i,1)=Dfit2(i,4)>=60;
        msd{i,1}=msd_one_particle_n(tracks_for_msd{i,1});
%         figure;
%         fig=gca;
%         hold on
%         plot(msd{i,1}(:,1),msd{i,1}(:,2),'color','b','Linewidth',1);
%         title({['MSD for molecule ' num2str(i) 'Annexin-A488 ', num2str(size(trajectory{i,1},1)), ' frames with dT = 6.8 ms']});
%         xlabel('Delay (s)');
%         ylabel('MSD (\mum^2)');
%         xt=[0.05];
%         yt=[0.003];
%         str={['STDx =' num2str(Dfit2(i,3)) 'nm STDy =' num2str(Dfit2(i,4)) 'nm' ]};
%         text(xt,yt,str,'HorizontalAlignment','center','FontSize',15);
%         hold off
%         filename=sprintf('MSD_molecules%s.png',num2str(i));
%         saveas(fig,filename);
%         filename=sprintf('MSD_molecules1%s.fig',num2str(i));
%         saveas(fig,filename);
        j=size(trajectories{1,i},1)-3; %number of points to fit MSD
        
        figure;
        fig=gca;
        hold on
        x(1,:)=transpose(msd{i,1}(:,1));
        y(1,:)=transpose(msd{i,1}(:,2));
        errbar(1,:)=transpose(msd{i,1}(:,3));
        mseb(x,y,errbar,[],1);
        msdfit1='a*x';
        startPoints=[0.5];
        [cf,gof]=fit(msd{i,1}(1:j,1),msd{i,1}(1:j,2),msdfit1,'Weights',msd{i,1}(1:j,3),'Start', startPoints);
        cf_coeff = coeffvalues(cf);
        cf_confint = confint(cf);
        a = cf_coeff(1);
        a_uncert = (cf_confint(2,1) - cf_confint(1,1))/2;
        Dfit2(i,1)=round((a/4)*1E3)/1E3; % diffusion coefficient
        Dfit2(i,2)=round((a_uncert/4)*1E3)/1E3; % fit error for D
        Dfit2(i,5)=gof.rsquare(1);
        mobile(i,1)=(Dfit2(i,2)/Dfit2(i,1)<=0.15);
        yfit=(a*x(1,:));
        if (Dfit2(i,5)>=0.8)
            plot(x(1,:),yfit,'color','r','Linewidth',2);
            legend('MSD','fit','Location','northwest');
            xt=[max(x(1,:))*0.75];
            yt=[max(y(1,:))*0.75];
            str={['D =' num2str(Dfit2(i,1)) '\mum^2/s' ]};
            text(xt,yt,str,'HorizontalAlignment','center','FontSize',15);
            title({['MSD for molecule ' num2str(i) ' RhPE ', num2str(size(trajectories{1,i},1)), ' frames with dT = 6.8 ms']});
            xlabel('Delay (s)');
            ylabel('MSD (\mum^2)');
            hold off
        else
           close
        end
        clear x y errbar;
        close 
%         filename=sprintf('MSD_molecules%s_fit.eps',num2str(i));
%         saveas(fig,filename);
%         filename=sprintf('MSD_molecules%s_fit.fig',num2str(i));
%         saveas(fig,filename);
        
        
%     else mobile(i,1)=Dfit2(i,3)>=40;
%         msd{i,1}=0;
    end
end
diffusion(:,1:5)=Dfit2(mobile,1:5);

save('diffusion.txt', 'diffusion', '-ascii')
clear diffusion;
percentil_mobile=round((size(nonzeros(mobile),1)/nparticles)*100);

 
