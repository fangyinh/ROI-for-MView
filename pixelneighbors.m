function [N Dist] = pixelneighbors(siz,i,j,h)
%
% Adam Lammert (2010)
%
% Determine the neighbors to an pixel (using subscripts)
%
% INPUT
%    siz : size of the image (i.e., [height width])
%    i : the input height subscript
%    j : the input width subscript
%    h : neighborhood size (circum.)
%
% OUTPUT
%    N : a matrix of neighbor subscripts
%

%Parameters
fheight = siz(1);
fwidth = siz(2);

% %Build Distance Map
% D = zeros(fheight,fwidth);
% for itor = 1:fheight
%     for jtor = 1:fwidth
%         D(itor,jtor) = sqrt(sum(([i j]-[itor jtor]).^2));
%     end
% end
% %D(i,j) = sqrt(fheight*fwidth);
% D = reshape(D,fheight*fwidth,1);

%Build Distance Map
D = zeros(fheight,fwidth);
D1 = repmat((1:siz(1))',1,siz(2));
D2 = repmat((1:siz(2)),siz(2),1);
E1 = repmat(i,68,68);
E2 = repmat(j,68,68);
D = sqrt((D1-E1).^2+(D2-E2).^2);

%Pixels Less than Maximum Distance
ind = find(D <= h);
[y x] = ind2sub(siz,ind);

%Build Output
N = [y x];
Dist = D(ind);

return
%eof