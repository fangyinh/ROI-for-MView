function [M] = vr2Matrix(vr)
%
% Adam Lammert (2010)
% Modified by Reed Blaylock (2014) to make compatible with VideoReader and
% to consolidate code
%
% Convert Avi file to Matrix of Frames
%
% INPUT 
%   vr: VideoReader object
% OUTPUT
%   M: the normalized movie matrix 
%       (rows are frames, columns are linearly indexed pixels)

% Get data from VideoReader
vidFrames = read(vr);
numFrames = vr.NumberOfFrames;

% Convert VideoReader output to something usable
for k = 1 : numFrames
	mov(k).cdata = vidFrames(:,:,:,k);
	mov(k).colormap = [];
end

% Get movie information
frame_height = vr.Height;
frame_width = vr.Width;
vec_length = frame_height*frame_width;

% Reshape matrix
M = zeros(numFrames,vec_length);
for itor = 1:numFrames
    M(itor,:) = reshape(double(mov(itor).cdata(:,:,1)),1,vec_length);
end

% Normalize matrix
M = M./repmat(mean(M,2),1,size(M,2));

return
%eof