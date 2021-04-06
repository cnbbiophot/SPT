function [DataFilterInt] = data_clean_by_intensity(Input,DataPerFrame,DataFilterFWHM)
%removes from the DataperFrame Structure all data that have intensity smaller than Intmin.

%% INPUT:

%Input: Input structure from SPTAna_01
%DataPerFrame: struct with cells for all information data separates by frame
%DataFilterFWHM:struct with cells for all information data separates by
%   frame and already filtered removing all localization out of range for Astigmatism and FWHM. 
%   This is necessary so the valid localization array starts considering the already removed 
%   localizations.

%% OUTPUT:

%DataPerFrameInt: struct with cells for all information data separated by
%frame and already filtered removing all localization with intensity
%smaller than Intmin

%% Created by: CVS June 2018
%jri 26Abr19
%CVS May2020 

%% Variable Setup

DataFilterInt=struct;
numFrames=Input.numFrames;
minLimit=Input.Intmin;
PSFIntensityArray=DataPerFrame.intensity;


DataFilterInt.valid=DataFilterFWHM.valid;
DataFilterInt.numValidLocal=zeros(numFrames,1);
DataFilterInt.coord=cell(numFrames,1);
DataFilterInt.FWHM=cell(numFrames,1);
DataFilterInt.int=cell(numFrames,1);
DataFilterInt.backg=cell(numFrames,1);
DataFilterInt.Astig=cell(numFrames,1);
DataFilterInt.SNR=cell(numFrames,1);

%% Execution

for frame=1:numFrames
    numLocalisations=size(PSFIntensityArray{frame,1},1); %Número de partículas en el frame
    for localisation=1:numLocalisations
        if DataFilterInt.valid{frame}(localisation, 1)==true % check if the localization is valid
            PSFIntensity=PSFIntensityArray{frame}(localisation,1);
            if  (PSFIntensity>=minLimit) % check if the intensity is above the stabilished limit.
                DataFilterInt.numValidLocal(frame)=DataFilterInt.numValidLocal(frame)+1;
            else
                DataFilterInt.valid{frame}(localisation, 1)=false;
            end
        end
    end
end



for frame=1:numFrames
        validsC=DataFilterInt.valid{frame,1};
        DataFilterInt.coord{frame}=DataPerFrame.coords{frame}(validsC, :);
        DataFilterInt.FWHM{frame}=DataPerFrame.FWHM{frame}(validsC, :);
        DataFilterInt.int{frame}=DataPerFrame.intensity{frame}(validsC, :);
        DataFilterInt.backg{frame}=DataPerFrame.backg{frame}(validsC, :);
        DataFilterInt.Astig{frame}=DataPerFrame.Astig{frame}(validsC, :);
        DataFilterInt.SNR{frame}=DataPerFrame.SNR{frame}(validsC, :);
end


DataFilterInt.totalLoca=sum(DataFilterInt.numValidLocal);


if (DataFilterInt.totalLoca==0)
    fprintf(Input.fileID,'\nProgram Ended. No localizations were found with Intensity > %3.0f.',Input.Intmin);
    return
end

localisation=1;
for frame=1:numFrames
    if not(isempty(DataFilterInt.FWHM{frame})) 
        numLocalisations=DataFilterInt.numValidLocal(frame,1);
        FWHM_row(localisation:localisation+numLocalisations-1,1)=DataFilterInt.FWHM{frame}(:,1);
        FWHM_row(localisation:localisation+numLocalisations-1,2)=DataFilterInt.FWHM{frame}(:,2);
        Int_row(localisation:localisation+numLocalisations-1,1)=DataFilterInt.int{frame}(:,1);
        Back_row(localisation:localisation+numLocalisations-1,1)=DataFilterInt.backg{frame}(:,1);      
        Astig_row(localisation:localisation+numLocalisations-1,1)=DataFilterInt.Astig{frame}(:,1);      
        SNR_row(localisation:localisation+numLocalisations-1,1)=DataFilterInt.SNR{frame}(:,1);      
        localisation=localisation+numLocalisations;
    end
end

DataFilterInt.FWHMmean=mean(FWHM_row(:));
DataFilterInt.FWHMstd=std(FWHM_row(:));
DataFilterInt.Intmean=mean(Int_row);
DataFilterInt.Intstd=std(Int_row);
DataFilterInt.Astigmean=mean(Astig_row);
DataFilterInt.Astigstd=std(Astig_row);
DataFilterInt.SNRmean=mean(SNR_row);
DataFilterInt.SNRstd=std(SNR_row);
DataFilterInt.Backmean=mean(Back_row);
DataFilterInt.Backstd=std(Back_row);

end



