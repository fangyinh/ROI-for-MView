function [ts R] = regionsmanual(M,pixloc,h)
%
% Adam Lammert (2010)
%
% Correlated Region Analysis with Manual Selection
%
% INPUTS:
%   filename: file name of .avi movie
%   t: region radius
%   pixloc: seed pixel location [y x]
% OUTPUTS:
%   ts: time series corresp. to the Correlated Region
%   R: image mask corresp. to the Correlated Region
%   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETERMINE THE REGION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mov_length = size(M,1);
fheight = 68;
fwidth = 68;
vec_length = fheight*fwidth;

% Neighbors
[N Dist] = pixelneighbors([fheight fwidth],pixloc(1),pixloc(2),h);

%iteratively determine the region
R = zeros(68,68);
for itor = 1:size(N,1)
    R(N(itor,1),N(itor,2)) = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETERMINE THE TIME SERIES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ts = mean(M(:,R>0),2);



return







%eof