function [DataPerFrame] = frame_separator(InputData,frames)
%This function prepares the vector to be used in the analysis. It transforms the vector for each variable into cell
%arrays where each cell has the data for all localization on a give frame

%% INPUT:
%InputData: struct with all input data and calculated data. 
%frames: total number of frames. 

%% OUTPUT:
%DataPerFrame: struct with cells for all information data separates by frame

%% Created by: CVS 
%On July 12/2018 
%Edited by CVS June/2020: Input and OutPut with structs.
%
%
%% Variable Setup

DataPerFrame=struct;  %creates cell arrays to store the variables
coordt=(horzcat(InputData.x,InputData.y)); %concatenate x and y vectors to have a coordenates vector.
initial=1; % sets initial frame to 1
final=frames; %sets the final frame to the number of frames in the tif file. 
inifinal=zeros(frames);

%% Execution

for a=initial:final; % goes over all frames
            
   if a==1 % if it is the first frame
       locaI=1;  %set initial localization at frame 1 
       locaF=InputData.counts(a,2); % sets the final localization on frame 1 to the total number of localization at frame 1
       inifinal(a,1)=locaI; % store line number for the initial localization at frame 1 
       inifinal(a,2)=locaF; % store line number for the final localization at frame 1
       
   else % if it is any frame after the first one
       locaI=(inifinal(a-1,2)+1);  % line number for the first localization at frame a
       locaF=(sum(InputData.counts(1:a,2))); % line number for the last localization at frame a 
       inifinal(a,1)=locaI; % store line number for the initial localization at frame a 
       inifinal(a,2)=locaF; % store line number for the final localization at frame a
   end
   
   DataPerFrame.coords{a,1}=coordt(locaI:locaF,:); %populates cell a with the coordenates values for all localization in frame a
   DataPerFrame.framev{a,1}=(InputData.frame(locaI:locaF)); %populates cell a with the frame values for all localization in frame a, all values need to be equals to a
   DataPerFrame.amp{a,1}=InputData.Amplitud(locaI:locaF); %populates cell a with the amplitud values for all localization in frame a
   DataPerFrame.FWHM{a,1}=horzcat(InputData.FWHMx(locaI:locaF),InputData.FWHMy(locaI:locaF)); %populates cell a with the FWHM values for all localization in frame a
   DataPerFrame.residues{a,1}=(InputData.residueFitting(locaI:locaF)); %populates cell a with the residues values for all localization in frame a
   DataPerFrame.backg{a,1}=InputData.background(locaI:locaF); %populates cell a with the background values for all localization in frame a 
   DataPerFrame.intensity{a,1}=InputData.Intensity(locaI:locaF); %populates cell a with the intensity values for all localization in frame a
   DataPerFrame.sigma{a,1}=horzcat(InputData.sigmax(locaI:locaF),InputData.sigmay(locaI:locaF)); %populates cell a with the sigma values for all localization in frame a
   DataPerFrame.Astig{a,1}=(InputData.Astig(locaI:locaF)); %populates cell a with the astigmatism values for all localization in frame a
   DataPerFrame.SNR{a,1}=(InputData.SNR(locaI:locaF)); %populates cell a with the astigmatism values for all localization in frame a

end


end

