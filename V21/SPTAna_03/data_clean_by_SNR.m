function [DataFilterSNR] = data_clean_by_SNR(Input,DataPerFrame,DataFilterInt)
%removes from the DataperFrame Structure all data that have Signal Noise Ratio  smaller than SNRmin.

%% INPUT:

%Input: Input structure from SPTAna_01
%DataPerFrame: struct with cells for all information data separates by frame
%DataFilterInt:struct with cells for all information data separates by
%   frame and already filtered removing all localization out of range for Astigmatism, FWHM and Intensity. 
%   This is necessary so the valid localization array starts considering the already removed 
%   localizations.

%% OUTPUT:

%DataPerFrameInt: struct with cells for all information data separated by
%frame and already filtered removing all localization with intensity
%smaller than Intmin

%% Created by: CVS May 2020

%% Variable Setup

DataFilterSNR=struct;
numFrames=Input.numFrames;
minLimit=Input.SNRmin;
SNRArray=DataPerFrame.SNR;


DataFilterSNR.valid=DataFilterInt.valid;
DataFilterSNR.numValidLocal=zeros(numFrames,1);
DataFilterSNR.coord=cell(numFrames,1);
DataFilterSNR.FWHM=cell(numFrames,1);
DataFilterSNR.int=cell(numFrames,1);
DataFilterSNR.backg=cell(numFrames,1);
DataFilterSNR.Astig=cell(numFrames,1);
DataFilterSNR.SNR=cell(numFrames,1);

%% Execution

for frame=1:numFrames
    numLocalisations=size(SNRArray{frame,1},1); %Número de partículas en el frame
    for localisation=1:numLocalisations
        if DataFilterSNR.valid{frame}(localisation, 1)==true % check if the localization is valid
            SNR=SNRArray{frame}(localisation,1);
            if  (SNR>=minLimit) % check if the intensity is above the stabilished limit.
                DataFilterSNR.numValidLocal(frame)=DataFilterSNR.numValidLocal(frame)+1;
            else
                DataFilterSNR.valid{frame}(localisation, 1)=false;
            end
        end
    end
end



for frame=1:numFrames
        validsD=DataFilterSNR.valid{frame};
        DataFilterSNR.coord{frame}=DataPerFrame.coords{frame}(validsD, :);
        DataFilterSNR.FWHM{frame}=DataPerFrame.FWHM{frame}(validsD, :);
        DataFilterSNR.int{frame}=DataPerFrame.intensity{frame}(validsD, :);
        DataFilterSNR.backg{frame}=DataPerFrame.backg{frame}(validsD, :);
        DataFilterSNR.Astig{frame}=DataPerFrame.Astig{frame}(validsD, :);
        DataFilterSNR.SNR{frame}=DataPerFrame.SNR{frame}(validsD, :);
end

DataFilterSNR.totalLoca=sum(DataFilterSNR.numValidLocal);



if (DataFilterSNR.totalLoca==0)
    fprintf(Input.fileID,'\nProgram Ended. No localizations were found with SNR >= %3.0f.',Input.SNRmin);
    return
end


localisation=1;
for frame=1:numFrames
    if not(isempty(DataFilterSNR.FWHM{frame})) %si validLocalisation(frame)>0
        numLocalisations=DataFilterSNR.numValidLocal(frame,1);
        FWHM_row(localisation:localisation+numLocalisations-1,1)=DataFilterSNR.FWHM{frame}(:,1);
        FWHM_row(localisation:localisation+numLocalisations-1,2)=DataFilterSNR.FWHM{frame}(:,2);
        Int_row(localisation:localisation+numLocalisations-1,1)=DataFilterSNR.int{frame}(:,1);
        Back_row(localisation:localisation+numLocalisations-1,1)=DataFilterSNR.backg{frame}(:,1);      
        Astig_row(localisation:localisation+numLocalisations-1,1)=DataFilterSNR.Astig{frame}(:,1);      
        SNR_row(localisation:localisation+numLocalisations-1,1)=DataFilterSNR.SNR{frame}(:,1);      
        localisation=localisation+numLocalisations;
    end
end

DataFilterSNR.FWHMmean=mean(FWHM_row(:));
DataFilterSNR.FWHMstd=std(FWHM_row(:));
DataFilterSNR.Intmean=mean(Int_row);
DataFilterSNR.Intstd=std(Int_row);
DataFilterSNR.Astigmean=mean(Astig_row);
DataFilterSNR.Astigstd=std(Astig_row);
DataFilterSNR.SNRmean=mean(SNR_row);
DataFilterSNR.SNRstd=std(SNR_row);
DataFilterSNR.Backmean=mean(Back_row);
DataFilterSNR.Backstd=std(Back_row);

end



