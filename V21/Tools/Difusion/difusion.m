function [ difusion ] = difusion( fileName, numMinTrackSteps, STD_r_min)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

load(fileName, 'ParticleData','Input','ImageStr');


imSizeX=ImageStr.imageInfo(1,1).Width;
imSizeY=ImageStr.imageInfo(1,1).Height;
pixelSize=Input.PixelSize;
fileSave=Input.Save;

idx_valid=ParticleData.numFrames>(numMinTrackSteps-1);
ParticleDataIdx.minTrack = particle_idx_after(ParticleData,numMinTrackSteps,idx_valid,Input);

moleculeLongTrackDataArray=ParticleDataIdx.minTrack;

[trajectories] = plot_tracks_v20 (fileSave, moleculeLongTrackDataArray, imSizeX, imSizeY, pixelSize);
[ tracks_for_msd ] = transform_tracks(trajectories);

nparticles=size(moleculeLongTrackDataArray.coords,1);

msd=cell(nparticles,1);
Dfit2=zeros(nparticles,5);

for i=1:nparticles
    steps=size(trajectories{1,i},1);
    delta_r=zeros(steps-1,1);
    for j=1:steps-1
        xi=trajectories{1,i}(j,2);
        yi=trajectories{1,i}(j,3);
        xf=trajectories{1,i}(j+1,2);
        yf=trajectories{1,i}(j+1,3);
        delta_r(j)=sqrt((xf-xi)^2+(yf-yi)^2);
    end
    Dfit2(i,3)=mean(delta_r);  %mean displacement 
    Dfit2(i,4)=std(delta_r);   %standard desviation for the displacement
    if Dfit2(i,4)>=STD_r_min
        mobile(i,1)=Dfit2(i,4)>=STD_r_min;
        msd{i,1}=msd_one_particle_n(tracks_for_msd{i,1});
        j=size(trajectories{1,i},1)-4; %number of points to fit MSD
        x(1,:)=transpose(msd{i,1}(1:j-1,1));
        y(1,:)=transpose(msd{i,1}(1:j-1,2));
        errbar(1,:)=transpose(msd{i,1}(1:j-1,3));  
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
        Dfit2(i,6)=i;
        mobile(i,1)=((Dfit2(i,2)/Dfit2(i,1)<=0.25)&&(Dfit2(i,5)>=0.75));
        yfit=(a*x(1,:));
        %%
%Uncomment to plot MSD for each particle
        if (Dfit2(i,5)>=0.75)
            fig=figure('Name',['MSD  molecule ' num2str(i) ],'NumberTitle','off','Position', [10 10 1800 1200]);
            set(fig, 'PaperPositionMode', 'auto');
            axes1 = axes('Parent',fig,'FontSize',20);
            box(axes1,'on');
            hold(axes1,'all');
            fig=gca;
            hold on
            mseb(x,y,errbar,[],1);
            plot(x(1,:),yfit,'color','r','Linewidth',2);
            legend('MSD','fit','Location','northwest');
            xt=[max(x(1,:))*0.10];
            yt=[max(y(1,:))*0.85];
            Dp=(round(Dfit2(i,1)*100)/100);
            str={['D =' num2str(Dp,'%1.2f') ' \mum^2/s' ]};
            text(xt,yt,str,'HorizontalAlignment','center','FontSize',20);
            title({['MSD for molecule ' num2str(i) ' RhPE ', num2str(size(trajectories{1,i},1)), ' frames with dT = 6.8 ms']});
            xlabel('Delay (s)');
            ylabel('MSD (\mum^2)');
            hold off
            filename = sprintf('%s_msd_molecule_%s.jpg', fileSave,num2str(i));
            saveas(fig,filename)
            filename = sprintf('%s_msd_molecule_%s.fig', fileSave,num2str(i));
            saveas(fig,filename)
        end
%%
        clear x y errbar;
        close 
    end
end

difusion(:,1:6)=Dfit2(mobile,1:6);
diffusion_versus_STDdisplacement(fileSave,Dfit2(mobile,1:6));

filename = sprintf('%s_difusion_%sfr.txt', fileSave,num2str(numMinTrackSteps));
save(filename, 'difusion', '-ascii')

percentil_mobile=(round((size(nonzeros(mobile))/nparticles)*100));

fprintf('\n %2.1f %% of molecules are considered mobiles and are used to compute difusion \n',percentil_mobile);

percentil_mobile=round((size(difusion,1)/nparticles)*100);
fprintf('Percentage of mobile molecules: %3d.\nTotal number of Molecules: %3d.\nNumber of mobile molecules: %3d.\nConsidering mobile molecules with STD Deltar > %3d.\n', percentil_mobile, nparticles, size(difusion,1),STD_r_min);
fprintf('Mean Difussion: %1.2f um^2/s.\n', mean(difusion(:,1)));

save(fileName,'difusion','-append');

clear difusion;
end

