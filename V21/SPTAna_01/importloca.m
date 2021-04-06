function [inputData] = importloca(fileToRead1)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [X,Y,FRAME,INTENSITY,FWHMX,FWHMY,RESIDUEFITTING,BACKGROUND] =
%   IMPORTFILE(FILENAME) Reads data from text file FILENAME for the default
%   selection.
%
%   [X,Y,FRAME,INTENSITY,FWHMX,FWHMY,RESIDUEFITTING,BACKGROUND] =
%   IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from rows STARTROW
%   through ENDROW of text file FILENAME.
%%
% Import file
newData1 = importdata(fileToRead1);

%% Allocate imported array to column variable names
inputData.x = newData1.data(:,1);
inputData.y = newData1.data(:,2);
inputData.frame = newData1.data(:,3);
inputData.Amplitud = newData1.data(:,4);
inputData.FWHMx = newData1.data(:,5);
inputData.FWHMy = newData1.data(:,6);
inputData.residueFitting = newData1.data(:,7);
inputData.background = newData1.data(:,8);
end
