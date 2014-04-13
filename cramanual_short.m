function [ts, R] = cramanual_short(vr,M,tau,pixloc)
%
% Adam Lammert (2010)
%
% Correlated Region Analysis with Manual Selection
%
% INPUTS:
%	vr: VideoReader object
%   M: movie matrix
%   tau: threshold parameter
%   pixloc: seed pixel location [y x]
% OUTPUTS:
%   ts: time series corresp. to the Correlated Region
%   R: image mask corresp. to the Correlated Region
%   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETERMINE THE REGION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%frame data
fheight = vr.Height;
fwidth = vr.Width;
numFrames = vr.NumberOfFrames;

%correlation matrix
C = corrcoef(M);

%iteratively determine the region
R = zeros(68,68);

IDX = sub2ind([fheight fwidth],pixloc(1),pixloc(2));
im = reshape(C(IDX,:),fheight,fwidth);
BW = zeros(size(im));
BW(im>=tau) = 1;

CN = bwconncomp(BW,4);

dim = size(CN.PixelIdxList);
flag = 0;
count = 0;
while ((flag == 0) && (count < dim(2)))
    count = count + 1;
    flag = intersect(IDX,CN.PixelIdxList{count});
    if isempty(flag)
        flag=0;
    else
        flag = count;
    end
end

R(CN.PixelIdxList{flag}) = numFrames;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETERMINE THE TIME SERIES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ts = mean(M(:,R>1),2);

return

%eof