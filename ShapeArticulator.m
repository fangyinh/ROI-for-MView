classdef (Abstract) ShapeArticulator < Articulator
	%UNTITLED Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		tau
		searchRadius
		pixelMinimum
	end
	
	methods
		function [] = run(obj,points,vidMatrix,numFrames)
			px = points(1,1);
			py = points(1,2);
			minx = px - obj.searchRadius;
			maxx = px + obj.searchRadius;
			miny = py - obj.searchRadius;
			maxy = py + obj.searchRadius;

			dynamic_range = 0.000;
			x = 0;
			y = 0;
			ts_raw = [];
			mask = [];
			
			for i = minx:maxx
				for j = miny:maxy
					[ts_cra_ij, mask_ij] = obj.findTimeSeries(vidMatrix,[j i],numFrames);

					pixelCount = numel(mask_ij( mask_ij(:)>0 ));
					if pixelCount >= obj.pixelMinimum
						filt_range = range(ts_cra_ij);

						if filt_range > dynamic_range
							dynamic_range = filt_range;
							ts_raw = ts_cra_ij;
							mask = mask_ij;
							x = i;
							y = j;
						end
					end
				end
			end
			
			obj.ts_raw = ts_raw;
			obj.ts_filt = obj.filter(ts_raw);
			obj.mask = mask;
			obj.x = x;
			obj.y = y;
		end
	end
	
	methods (Access = protected)
		function [ts_raw, mask] = findTimeSeries(obj,vidMatrix,pixloc,numFrames)
% 			
% 			Adam Lammert (2010)
% 			
% 			Correlated Region Analysis with Manual Selection
% 			
% 			INPUTS:
%			  vr: VideoReader object
% 			  M: movie matrix
% 			  tau: threshold parameter
% 			  pixloc: seed pixel location [y x]
% 			OUTPUTS:
% 			  ts: time series corresp. to the Correlated Region
% 			  R: image mask corresp. to the Correlated Region
% 			  

			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% DETERMINE THE REGION
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			%frame data
			fheight = 68;
			fwidth = 68;

			%correlation matrix
			C = corrcoef(vidMatrix);

			%iteratively determine the region
			mask = zeros(68,68);

			IDX = sub2ind([fheight fwidth],pixloc(1),pixloc(2));
			im = reshape(C(IDX,:),fheight,fwidth);
			BW = zeros(size(im));
			BW(im>=obj.tau) = 1;

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

			mask(CN.PixelIdxList{flag}) = numFrames;

			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% DETERMINE THE TIME SERIES
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			ts_raw = mean(vidMatrix(:,mask>1),2);
		end
	end
	
end

