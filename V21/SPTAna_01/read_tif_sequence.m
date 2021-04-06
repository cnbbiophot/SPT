function [ImageStr] = read_tif_sequence(fname,initialFrame,finalFrame)
% function [InfoImages,num_images] = read_tif_sequence(fname)
%Opens a sequences of images in a cell array with the rows being the
%frames. 
%% INPUT:

%fname: name of the tif file that has a sequence of images.
%initialFrame: number of the frame to start analysis.
%finalFrame: last frame to finish analysis.

%% OUTPUT: 
%
%ImageStr: structure with all the informations about the tif file to be
    %analyzed. Including:
    %ImageSeq: cell array. Each cell is the matrix for one image. 
    %InfoImage: cell array. Each cell is the information for one image.
    %NumberImages: Number of images in the sequence.
    %frames: total number of frames to be analyzed. 

%% Variables Setup
ImageStr=struct;

ImageStr.imageInfo=imfinfo(fname);
ImageStr.NumberImages=length(ImageStr.imageInfo);
ImageStr.filename=fname;

if finalFrame<0
	finalFrame=ImageStr.NumberImages;
end
if initialFrame==0
 	initialFrame=1;
end
ImageStr.initialFr=initialFrame;
ImageStr.finalFr=finalFrame;

frames=finalFrame-initialFrame+1;
ImageStr.nframes=frames;

ImageSeq=cell(frames,1);

%% Execution

for n=initialFrame:finalFrame
    ImageSeq{(n+1-initialFrame)}=imread(fname, n);
end
ImageStr.images=ImageSeq;

end

