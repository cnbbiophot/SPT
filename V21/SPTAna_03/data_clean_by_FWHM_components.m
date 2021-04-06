function [DataFilterFWHM] = data_clean_by_FWHM_components(Input,DataPerFrame,DataFilterAstg)
% removes from the DataperFrame Structure all data that have FWHM values bigger that FWHMmax and smaller than FWHMmin.

%% INPUT:

%Input: Input structure from SPTAna_01
%DataFilterAstg:struct with cells for all information data separates by
%   frame and already filtered removing all localization out of range for Astigmatism. 
%   This is necessary so the valid localization array starts considering the already removed 
%   localizations.

%% OUTPUT:

%DataPerFrameFWHM: struct with cells for all information data separates by
%frame and already filtered removing all localization out of the FWHM 
%specified range. 

%% Created by: CVS June 2018
% Edited by jri 26Abr19
% CVS March/2020

%% Variable Setup

DataFilterFWHM=struct;
numFrames=Input.numFrames;
PSFArray=DataPerFrame.FWHM;
minLimit=Input.FWHMmin;
maxLimit=Input.FWHMmax;

DataFilterFWHM.valid=DataFilterAstg.valid;
DataFilterFWHM.numValidLocal=zeros(numFrames,1);
DataFilterFWHM.coord=cell(numFrames,1);
DataFilterFWHM.FWHM=cell(numFrames,1);
DataFilterFWHM.int=cell(numFrames,1);
DataFilterFWHM.backg=cell(numFrames,1);
DataFilterFWHM.Astig=cell(numFrames,1);
DataFilterFWHM.SNR=cell(numFrames,1);

%% Execution

for frame=1:numFrames
    numLocalisations=size(PSFArray{frame,1},1); %Número de partículas en el frame
    for localisation=1:numLocalisations
        if DataFilterFWHM.valid{frame}(localisation, 1)==true %check if particle is still valid
            PSFx=PSFArray{frame}(localisation, 1);
            PSFy=PSFArray{frame}(localisation, 2);
            if  and(PSFx<=maxLimit,PSFy<=maxLimit) % check if the PSFx and PSFy value are below the stabilished limit.
                if  and(PSFx>=minLimit,PSFy>=minLimit) % check if the PSFx and PSFy value are above the stabilished limit.
                    DataFilterFWHM.numValidLocal(frame)=DataFilterFWHM.numValidLocal(frame)+1;
                else
                    DataFilterFWHM.valid{frame}(localisation, 1)=false;
                end
            else
                DataFilterFWHM.valid{frame}(localisation, 1)=false;
            end
        end
    end
end

for frame=1:numFrames
        validsB=DataFilterFWHM.valid{frame};
        DataFilterFWHM.coord{frame}=DataPerFrame.coords{frame}(validsB, :);
        DataFilterFWHM.FWHM{frame}=DataPerFrame.FWHM{frame}(validsB, :);
        DataFilterFWHM.int{frame}=DataPerFrame.intensity{frame}(validsB, :);
        DataFilterFWHM.backg{frame}=DataPerFrame.backg{frame}(validsB, :);
        DataFilterFWHM.Astig{frame}=DataPerFrame.Astig{frame}(validsB, :);
        DataFilterFWHM.SNR{frame}=DataPerFrame.SNR{frame}(validsB, :);
end


DataFilterFWHM.totalLoca=sum(DataFilterFWHM.numValidLocal);


if (DataFilterFWHM.totalLoca==0)
    fprintf(Input.fileID,'\nProgram Ended. No localizations were found with %3.0f < FWHM < %3.0f.',Input.FWHMmin,Input.FWHMmax);
    return
end


localisation=1;
for frame=1:numFrames
    if not(isempty(DataFilterFWHM.FWHM{frame})) %si validLocalisation(frame)>0
        numLocalisations=size(DataFilterFWHM.FWHM{frame,1},1);
        FWHM_row(localisation:localisation+numLocalisations-1,1)=DataFilterFWHM.FWHM{frame}(:,1);
        FWHM_row(localisation:localisation+numLocalisations-1,2)=DataFilterFWHM.FWHM{frame}(:,2);
        Int_row(localisation:localisation+numLocalisations-1,1)=DataFilterFWHM.int{frame}(:,1);
        Back_row(localisation:localisation+numLocalisations-1,1)=DataFilterFWHM.backg{frame}(:,1);      
        Astig_row(localisation:localisation+numLocalisations-1,1)=DataFilterFWHM.Astig{frame}(:,1);      
        SNR_row(localisation:localisation+numLocalisations-1,1)=DataFilterFWHM.SNR{frame}(:,1);      
        localisation=localisation+numLocalisations;
    end
end

DataFilterFWHM.FWHMmean=mean(FWHM_row(:));
DataFilterFWHM.FWHMstd=std(FWHM_row(:));
DataFilterFWHM.Intmean=mean(Int_row);
DataFilterFWHM.Intstd=std(Int_row);
DataFilterFWHM.Astigmean=mean(Astig_row);
DataFilterFWHM.Astigstd=std(Astig_row);
DataFilterFWHM.SNRmean=mean(SNR_row);
DataFilterFWHM.SNRstd=std(SNR_row);
DataFilterFWHM.Backmean=mean(Back_row);
DataFilterFWHM.Backstd=std(Back_row);

clear FWHM_row Int_row Astig_row SNR_row Back_row 

end




