function [DataFilterAstg] = data_clean_by_astigmatism(Input, DataPerFrame)
% removes from the DataperFrame Structure all data that have astigmatism values bigger that Astgmax and smaller than Astgmin.

%% INPUT:

%Input: Input structure from SPTAna_01
%DataPerFrame: struct with cells for all information data separates by frame

%% OUTPUT:

%DataFilterAstg: struct with cells for all information data separates by
%frame and already filtered removing all localizations with Astigmatism values out of the
%specified range. 

%% Created by: CVS 
%On March/2020

%% Variable Setup

DataFilterAstg=struct;
numFrames=Input.numFrames;
minLimit=Input.Astgmin;
maxLimit=Input.Astgmax;
AstgArray=DataPerFrame.Astig;

DataFilterAstg.valid=cell(numFrames, 1);
DataFilterAstg.numValidLocalisations=zeros(numFrames,1);
DataFilterAstg.coord=cell(numFrames,1);
DataFilterAstg.FWHM=cell(numFrames,1);
DataFilterAstg.int=cell(numFrames,1);
DataFilterAstg.backg=cell(numFrames,1);
DataFilterAstg.Astig=cell(numFrames,1);
DataFilterAstg.SNR=cell(numFrames,1);

%% Execution

for frame=1:numFrames
    numLocalisations=size(AstgArray{frame,1},1); %Número de partículas en el frame
    DataFilterAstg.valid{frame}=false(numLocalisations, 1);
    for localisation=1:numLocalisations
        AST=AstgArray{frame}(localisation, 1);
        if  (AST<=maxLimit) % check if the astigmatism value is smaller than the maximum the stabilished limit.
            if  (AST>=minLimit) % check if the astigmatism value is bigger than the minimum limit.
                DataFilterAstg.valid{frame}(localisation)=true;
                DataFilterAstg.numValidLocalisations(frame)=DataFilterAstg.numValidLocalisations(frame)+1;
            end
        end
    end
end

DataFilterAstg.totalLoca=sum(DataFilterAstg.numValidLocalisations);

if (DataFilterAstg.totalLoca==0)
    fprintf(Input.fileID,'\nProgram Ended. No localizations were found with %1.2f < Astigmatism < %1.2f.',Input.Astgmin,Input.Astgmax);
    return
end

for frame=1:numFrames
    validsA=DataFilterAstg.valid{frame};
    DataFilterAstg.coord{frame}=DataPerFrame.coords{frame}(validsA, :);
    DataFilterAstg.FWHM{frame}=DataPerFrame.FWHM{frame}(validsA, :);
    DataFilterAstg.int{frame}=DataPerFrame.intensity{frame}(validsA, :);
    DataFilterAstg.backg{frame}=DataPerFrame.backg{frame}(validsA, :);
    DataFilterAstg.Astig{frame}=DataPerFrame.Astig{frame}(validsA, :);
    DataFilterAstg.SNR{frame}=DataPerFrame.SNR{frame}(validsA, :);
end

localisation=1;
for frame=1:numFrames
    if not(isempty(DataFilterAstg.FWHM{frame})) %si validLocalisation(frame)>0
        numLocalisations=size(DataFilterAstg.FWHM{frame,1},1);
        FWHM_row(localisation:localisation+numLocalisations-1,1)=DataFilterAstg.FWHM{frame}(:,1);
        FWHM_row(localisation:localisation+numLocalisations-1,2)=DataFilterAstg.FWHM{frame}(:,2);
        Int_row(localisation:localisation+numLocalisations-1,1)=DataFilterAstg.int{frame}(:,1);
        Back_row(localisation:localisation+numLocalisations-1,1)=DataFilterAstg.backg{frame}(:,1);      
        Astig_row(localisation:localisation+numLocalisations-1,1)=DataFilterAstg.Astig{frame}(:,1);      
        SNR_row(localisation:localisation+numLocalisations-1,1)=DataFilterAstg.SNR{frame}(:,1);      
        localisation=localisation+numLocalisations;
    end
end

DataFilterAstg.FWHMmean=mean(FWHM_row(:));
DataFilterAstg.FWHMstd=std(FWHM_row(:));
DataFilterAstg.Intmean=mean(Int_row);
DataFilterAstg.Intstd=std(Int_row);
DataFilterAstg.Astigmean=mean(Astig_row);
DataFilterAstg.Astigstd=std(Astig_row);
DataFilterAstg.SNRmean=mean(SNR_row);
DataFilterAstg.SNRstd=std(SNR_row);
DataFilterAstg.Backmean=mean(Back_row);
DataFilterAstg.Backstd=std(Back_row);

clear FWHM_row Int_row Back_row Astig_row SNR_row 
end



