function [Input,InputData] = intensity_from_amplitude(Input,InputData)
%Calculates the intesity for a given list of localizations using the
%   equation intensity Io = A/(2*pi*sigmax*sigmay)
%   Also calculates the astigmatism for the FWHM. 

%% INPUT: 
%Input: Input structure from SPTAna_01
%InputData: Input Data structure from SPTAna_01

%% OUTPUT:
%Astigmatism, sigmax , sigmay and Intensity are matrix added to InputData
%structure

%% Create by CVS March/2020
%%UPDATES: 
%Edited 2020.03.16 - CVS: Change data type to struct
%Edited 2020.03.19 - CVS: Added SNR calculation

%% Execution

InputData.Astig=InputData.FWHMx ./ InputData.FWHMy;   %Astigmatism FWHM x / FWHM y
InputData.sigmax=InputData.FWHMx ./ (2*sqrt(2*log(2))) / Input.PixelSize;
InputData.sigmay=InputData.FWHMy ./ (2*sqrt(2*log(2))) / Input.PixelSize;
InputData.Intensity = InputData.Amplitud ./ (2*pi().*InputData.sigmax.*InputData.sigmay);
InputData.SNR=InputData.Amplitud ./ InputData.background;



end
