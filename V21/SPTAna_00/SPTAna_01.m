function [ImageStr,InputData,Input] = SPTAna_01(Input)
%%%Loading DATA 
fprintf(Input.fileID,'\nStep 1 - Loading Raw Data...');

%%Reading TIF file
fprintf(Input.fileID,'\n           Reading TIF file and Import data...');


[ImageStr] = read_tif_sequence(Input.ImageName,Input.initialFrame,Input.finalFrame); % read tif file and informations from it, returns a struct with the data

save(Input.Save,'ImageStr', '-append');

%% Set the size of the image

Lx=ImageStr.imageInfo(1,1).Width; %sets the width of the image
Ly=ImageStr.imageInfo(1,1).Height; %sets the height of the image

fprintf(Input.fileID,'\n               File: %s', ImageStr.filename);
fprintf(Input.fileID,'\n               Images: %3d',ImageStr.NumberImages);
fprintf(Input.fileID,'\n               Size: %3d x %3d pixels',Lx,Ly);
fprintf(Input.fileID,'\n           Analysis will done in:');
fprintf(Input.fileID,'\n               Initial Frame:%3d.', ImageStr.initialFr);
fprintf(Input.fileID,'\n               Final Frame:%3d.',ImageStr.finalFr);
fprintf(Input.fileID,'\n               Total Number of Frames: %3d.',ImageStr.nframes);


%% Importing coordenates and counts and preparing the vectors. 

fprintf(Input.fileID,'\n           Importing files localization and counts for all frames...');

fprintf(Input.fileID,'\n               Counts file: %s.', Input.Counts);
fprintf(Input.fileID,'\n               Localization file: %s.', Input.Localizations);

[InputData] = import_files(Input.Localizations,Input.Counts,ImageStr);
Input.totalLoca=numel(InputData.x);
InputData.background=InputData.backgroundrS-Input.DarkIntensityCamera;

if  (sum(InputData.counts(:,2))~=numel(InputData.frame))
    msg=['\nERROR: Number of Localizations on %s file is not the same as the number of counts on %s file. Check output files from rapidStorm. ',Input.Localizations,Input.Counts];
    error(msg);
end

save(Input.Save,'InputData', '-append');

fprintf(Input.fileID,'\n               Total number of Localizations found on input files: %d in %d frames,',numel(InputData.x),ImageStr.nframes);
fprintf(Input.fileID,'\n                  (around %5.0f localizations/frame).',(numel(InputData.x)./ImageStr.nframes));
fprintf(Input.fileID,'\n               Camera Dark Intensity: %3.0f ',Input.DarkIntensityCamera);
fprintf(Input.fileID,'\n         Reading TIF file and Import data - Done!\n');



end

