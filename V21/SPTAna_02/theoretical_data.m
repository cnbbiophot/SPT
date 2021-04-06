function [ TheoreticalData ] = theoretical_data(lambda,numericalAperture)
%Calculates the FWHM and the resolution given de wavelength and the NA.

%% INPUT: 
%lambda: Wavelength of excitation
%numericalAperture: numerical Aperture of the objective used. 

%% OUTPUT:
%TheoreticalData: theoretical value for the Point Spread Function

%% Create by CVS 18 July/2018
%%UPDATES: 
%1.Corrected by CVS 23 July/2018
%2.Change the name of files and added structure

%% Execution

TheoreticalData=struct;

TheoreticalData.sigma=int16(0.21*(lambda./numericalAperture));
TheoreticalData.r_airy=int16((0.61./0.21)*TheoreticalData.sigma);
TheoreticalData.wo=int16(2*TheoreticalData.sigma);
TheoreticalData.FWHM=int16((2*sqrt(2*log(2))*TheoreticalData.sigma));
TheoreticalData.rRayleigh=int16(0.61*(lambda/numericalAperture)); % calculates the Rayleigh resolution using the value given by the user for wavelength(lambda) and numerical aperture pf the objective. 
TheoreticalData.rSparrow=int16(0.47*(lambda/numericalAperture));

end

