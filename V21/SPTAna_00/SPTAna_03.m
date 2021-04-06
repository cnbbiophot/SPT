function [DataFilterAstg,DataFilterFWHM,DataFilterInt,DataFilterSNR] =SPTAna_03(Input,DataPerFrame)

fprintf(Input.fileID,'\nStep 3 - Filtering Localizations to remove noise...');

numFrames=Input.numFrames;
total_local=0;
for frame=1:numFrames
    numLocalisations=size(DataPerFrame.FWHM {frame,1},1);
    total_local=total_local+numLocalisations; 
end
DataPerFrame.totalLoca=total_local;

%%
%%%
%%Removing FWHM that have asimetric FWHM values 


[DataFilterAstg] = data_clean_by_astigmatism(Input, DataPerFrame);


fprintf(Input.fileID,'\n           Input Data AFTER filtering BY ASTIGMATISM [%1.2f =< - >= %1.2f]:', Input.Astgmin, Input.Astgmax);
fprintf(Input.fileID,'\n               Localizations: %3.0f', DataFilterAstg.totalLoca);
fprintf(Input.fileID,'\n               Percentage of Remaining Localizations: %2.1f%%).', (DataFilterAstg.totalLoca/DataPerFrame.totalLoca)*100);
fprintf(Input.fileID,'\n               Mean FWHM %3.0f±%3.0f ',DataFilterAstg.FWHMmean,DataFilterAstg.FWHMstd);
fprintf(Input.fileID,'\n               Mean Intenisty %3.0f±%3.0f ',DataFilterAstg.Intmean,DataFilterAstg.Intstd);
fprintf(Input.fileID,'\n               Mean Background %3.0f±%3.0f ',DataFilterAstg.Backmean,DataFilterAstg.Backstd);
fprintf(Input.fileID,'\n               Mean SNR %2.0f±%2.0f ',DataFilterAstg.SNRmean,DataFilterAstg.SNRstd);
fprintf(Input.fileID,'\n               Mean Astigmatism %1.1f±%1.1f ',DataFilterAstg.Astigmean,DataFilterAstg.Astigstd);

%% Removing FWHM values that are out of the range defined in the input.

[DataFilterFWHM] = data_clean_by_FWHM_components(Input,DataPerFrame,DataFilterAstg);

fprintf(Input.fileID,'\n           Input Data AFTER filtering BY FWHM VALUES [%1.2f =< - >= %1.2f]:', Input.FWHMmin, Input.FWHMmax);
fprintf(Input.fileID,'\n               Localizations: %3.0f', DataFilterFWHM.totalLoca);
fprintf(Input.fileID,'\n               Percentage of Remaining Localizations: %2.1f%%).', (DataFilterFWHM.totalLoca/DataPerFrame.totalLoca)*100);
fprintf(Input.fileID,'\n               Mean FWHM %3.0f±%3.0f ',DataFilterFWHM.FWHMmean,DataFilterFWHM.FWHMstd);
fprintf(Input.fileID,'\n               Mean Intenisty %3.0f±%3.0f ',DataFilterFWHM.Intmean,DataFilterFWHM.Intstd);
fprintf(Input.fileID,'\n               Mean Background %3.0f±%3.0f ',DataFilterFWHM.Backmean,DataFilterFWHM.Backstd);
fprintf(Input.fileID,'\n               Mean SNR %2.0f±%2.0f ',DataFilterFWHM.SNRmean,DataFilterFWHM.SNRstd);
fprintf(Input.fileID,'\n               Mean Astigmatism %1.1f±%1.1f ',DataFilterFWHM.Astigmean,DataFilterFWHM.Astigstd);


%% Removing localizations that have PSF intensity values smaller than the minimum stabilished at the Input. 

[DataFilterInt] = data_clean_by_intensity (Input,DataPerFrame,DataFilterFWHM); % removes from the PSF the values that are bigger than 2 x the Rayleigh resolution


fprintf(Input.fileID,'\n           Input Data AFTER filtering BY INTENSITY VALUES [>=  %3.0f]:', Input.Intmin);
fprintf(Input.fileID,'\n               Localizations: %3.0f', DataFilterInt.totalLoca);
fprintf(Input.fileID,'\n               Percentage of Remaining Localizations: %2.1f%%', (DataFilterInt.totalLoca/DataPerFrame.totalLoca)*100);
fprintf(Input.fileID,'\n               Mean FWHM %3.0f±%3.0f',DataFilterInt.FWHMmean,DataFilterInt.FWHMstd);
fprintf(Input.fileID,'\n               Mean Intenisty %3.0f±%3.0f ',DataFilterInt.Intmean,DataFilterInt.Intstd);
fprintf(Input.fileID,'\n               Mean Background %3.0f±%3.0f ',DataFilterInt.Backmean,DataFilterInt.Backstd);
fprintf(Input.fileID,'\n               Mean SNR %2.0f±%2.0f',DataFilterInt.SNRmean,DataFilterInt.SNRstd);
fprintf(Input.fileID,'\n               Mean Astigmatism %1.1f±%1.1f ',DataFilterInt.Astigmean,DataFilterInt.Astigstd);

%% Removing localizations that have SNR values smaller than the minimum stabilished at the Input. 

[DataFilterSNR] = data_clean_by_SNR (Input,DataPerFrame,DataFilterInt); % removes from the PSF the values that are bigger than 2 x the Rayleigh resolution


fprintf(Input.fileID,'\n           Input Data AFTER filtering BY SNR VALUES [>=  %1.2f]:', Input.SNRmin);
fprintf(Input.fileID,'\n               Localizations: %3.0f', DataFilterSNR.totalLoca);
fprintf(Input.fileID,'\n               Percentage of Remaining Localizations: %2.1f%%', (DataFilterSNR.totalLoca/DataPerFrame.totalLoca)*100);
fprintf(Input.fileID,'\n               Mean FWHM %3.0f±%3.0f',DataFilterSNR.FWHMmean,DataFilterSNR.FWHMstd);
fprintf(Input.fileID,'\n               Mean Intenisty %3.0f±%3.0f ',DataFilterSNR.Intmean,DataFilterSNR.Intstd);
fprintf(Input.fileID,'\n               Mean Background %3.0f±%3.0f ',DataFilterSNR.Backmean,DataFilterSNR.Backstd);
fprintf(Input.fileID,'\n               Mean SNR %2.0f±%2.0f',DataFilterSNR.SNRmean,DataFilterSNR.SNRstd);
fprintf(Input.fileID,'\n               Mean Astigmatism %1.1f±%1.1f ',DataFilterSNR.Astigmean,DataFilterSNR.Astigstd);

fprintf(Input.fileID,'\n         Removing Noise - Done!\n');
