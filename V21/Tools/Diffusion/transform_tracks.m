function [ tracks_new ] = transform_tracks(tracks)
%transform tracks to be  size N x (nDim+1) with [ T0 X0 Y0 ... ] etc...
%INPUT:

%OUTPUT:

%CVS 2019.06.24 - Created

tracks=transpose(tracks);
Nparticles = numel(tracks);
tracks_new=cell(size(tracks,1),1);

for n=1:Nparticles
    tracks_new{n,1}(:,1)=tracks{n,1}(:,1) ./ 1000; % transform from mseconds to seconds
    tracks_new{n,1}(:,2)=tracks{n,1}(:,2) ./ 1000; % transform from nm to um
    tracks_new{n,1}(:,3)=tracks{n,1}(:,3) ./ 1000; % transform from nm to um
   
end


end

