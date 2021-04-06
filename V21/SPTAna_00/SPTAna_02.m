function [TheoreticalData,InputData,DataPerFrame] =SPTAna_02(Input,InputData)
%% Prepare data and calculates relevant data to be analyzed
fprintf(Input.fileID,'\nStep 2 - Preparing Data...');


%% Calculating Theoretical PSF for the system:


[ TheoreticalData ] = theoretical_data(Input.Lambda,Input.NA); %calculates the theoretical PSF using the value given by the user for wavelength(lambda) and numerical aperture of the objective. 
save(Input.Save,'TheoreticalData', '-append');

fprintf(Input.fileID,'\n           Considering:');
fprintf(Input.fileID,'\n               Emission wavelength %3.1d nm ',Input.Lambda);
fprintf(Input.fileID,'\n               NA = %3.2f:              ',Input.NA);
fprintf(Input.fileID,'\n           Rayleigh resolution is %3.1f nm ', TheoreticalData.rRayleigh);
fprintf(Input.fileID,'\n           Theoretical FWHM is %3.1f nm.',TheoreticalData.FWHM);


%% Calculating Intensity from Amplitud, Astigmatism and SNR

[Input,InputData] = intensity_from_amplitude(Input,InputData);

save(Input.Save,'InputData', '-append');

InputData.meanInt=mean(InputData.Intensity);
InputData.stdInt=std(InputData.Intensity);

fprintf(Input.fileID,'\n           Input Data before filtering:');
fprintf(Input.fileID,'\n               Mean Intenisty %3.0f±%3.0f ',InputData.meanInt,InputData.stdInt);

InputData.meanBck=mean(InputData.background);
InputData.stdBck=std(InputData.background);
fprintf(Input.fileID,'\n               Mean Background %3.0f±%3.0f ',InputData.meanBck,InputData.stdBck);

InputData.meanSNR=mean(InputData.SNR);
InputData.stdSNR=std(InputData.SNR);
fprintf(Input.fileID,'\n               Mean SNR %2.1f±%2.1f ',InputData.meanSNR,InputData.stdSNR);

InputData.meanAst=mean(InputData.Astig);
InputData.stdAst=std(InputData.Astig);
fprintf(Input.fileID,'\n               Mean Astigmatism %1.1f±%1.1f ',InputData.meanAst,InputData.stdAst);

%% Data per frame

fprintf(Input.fileID,'\n           Separating Data per Frame...');

[DataPerFrame] = frame_separator(InputData,Input.numFrames); %prepare vector to be used during the program
save(Input.Save,'DataPerFrame', '-append');


fprintf(Input.fileID,'\n         Preparing Data - Done!\n');