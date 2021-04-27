function [diffusion] = msd_fit_brownian_error(fileName,fileSave, delta_r_threshold,numMinTrackSteps)


load(fileName, 'ParticleData','Input','ImageStr');


imSizeX=ImageStr.imageInfo(1,1).Width;
imSizeY=ImageStr.imageInfo(1,1).Height;
pixelSize=Input.PixelSize;

idx_valid=ParticleData.numFrames>(numMinTrackSteps-1);
ParticleDataIdx.minTrack = particle_idx_after(ParticleData,numMinTrackSteps,idx_valid,Input);

moleculeLongTrackDataArray=ParticleDataIdx.minTrack;

[trajectories] = plot_tracks_v20 (fileSave, moleculeLongTrackDataArray, imSizeX, imSizeY, pixelSize);
[ tracks_for_msd ] = transform_tracks(trajectories);

nparticles=size(moleculeLongTrackDataArray.coords,1);

if size(moleculeLongTrackDataArray,1)==0
    fprintf('No molecule to calculate MSD with frame treshold of %2d frames.\n', frame_threshold);
    return
end

msd=cell(nparticles,1);
Dfit2=zeros(nparticles,7);
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
    Dfit2(i,5)=var(delta_r); %displacement variance
    Dfit2(i,6)=i; %molecule number
    if Dfit2(i,4)>=delta_r_threshold
        mobile(i,1)=Dfit2(i,4)>=delta_r_threshold;
        msd{i,1}=msd_one_particle_n(tracks_for_msd{i,1});
        j=size(trajectories{1,i},1)-3; %number of points to fit MSD
        msdfit1='a*x';
        startPoints=[4];
%        [fitcurve,fitgoodness,fitoutput]=fit(msd{i,1}(1:j,1),msd{i,1}(1:j,2),msdfit1,'Weights',msd{i,1}(1:j,3),'Start', startPoints,'Algorithm','Levenberg-Marquardt');
        [fitcurve,fitgoodness,fitoutput]=fit(msd{i,1}(1:j,1),msd{i,1}(1:j,2),msdfit1,'Weights',msd{i,1}(1:j,3),'Start', startPoints);

        cf_coeff = coeffvalues(fitcurve);
        cf_confint = confint(fitcurve);
        a = cf_coeff(1);
        a_uncert = (cf_confint(2,1) - cf_confint(1,1))/2;
        Dfit2(i,1)=round((a/4)*1E3)/1E3; % diffusion coefficient
        Dfit2(i,2)=round((a_uncert/4)*1E3)/1E3; % fit error for D
        Dfit2(i,7)=fitgoodness.rsquare(1); % 
        mobile(i,1)=((Dfit2(i,2)/Dfit2(i,1)<=0.25)&&(Dfit2(i,7)>=0.75));
        %% Plot Figure to Debug
        if (Dfit2(i,7)>=0.75)
            figure;
            fig=gca;
            hold on
            x(1,:)=transpose(msd{i,1}(1:j,1));
            y(1,:)=transpose(msd{i,1}(1:j,2));
            errbar(1,:)=transpose(msd{i,1}(1:j,3));
            mseb(x,y,errbar,[],1);
            yfit=(a*x(1,:));
            plot(x(1,:),yfit,'color','r','Linewidth',2);
            legend('MSD', 'fit','Location','northwest');
            xt=[max(x(1,:))*0.75];
            yt=[max(y(1,:))*0.75];
            str={['D =' num2str(Dfit2(i,1),'%1.2f') ' \mum^2/s' ]};
            text(xt,yt,str,'HorizontalAlignment','center','FontSize',15);
%             xt=[max(x(1,:))*0.5];
%             yt=[max(y(1,:))*0.5];
%             str={['a =' num2str(a) ' linear' ]};
%             text(xt,yt,str,'HorizontalAlignment','center','FontSize',15);
            title({['MSD for molecule ' num2str(i) ' RhPE ', num2str(size(trajectories{1,i},1)), ' frames with dT = 6.8 ms']});
            xlabel('Delay (s)');
            ylabel('MSD (\mum^2)');
            %         axis([0 max(x(1,:))*1.2 0 max(y(1,:))*1.2]);
            hold off
            filename = sprintf('%s_msd_molecule_%s.jpg', fileSave,num2str(i)); 
            saveas(fig,filename)
            filename = sprintf('%s_msd_molecule_%s.fig', fileSave,num2str(i)); 
            saveas(fig,filename)
        else
            close
        end
        %%END DEBUG figure
        %%
        clear x y errbar;
%     else mobile(i,1)=Dfit2(i,4)delta_r_threshold;
%         msd{i,1}=0;
    end
end

diffusion_versus_STDdisplacement(fileSave,Dfit2(mobile,1:6));

diffusion(:,1:7)=Dfit2(mobile,1:7);
filename = sprintf('%s_diffusion_fit_errors.txt', fileSave); 
save(filename, 'diffusion', '-ascii')

percentil_mobile=round((size(diffusion,1)/nparticles)*100);
fprintf('Percentage of mobile molecules: %3d.\nTotal number of Molecules: %3d.\nNumber of mobile molecules: %3d.\nConsidering mobile molecules with STD Deltar > %3d.\n', percentil_mobile, nparticles, size(diffusion,1),delta_r_threshold);
fprintf('Mean Diffussion: %1.2f um^2/s.\n', mean(diffusion(:,1)));

save(fileName,'Dfit2','msd','mobile','-append');


end

