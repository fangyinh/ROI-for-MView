classdef (Abstract) ShapeArticulator < Articulator
	%	ShapeArticulator Abstract subclass of Articulator
	%   ShapeArticulator is a subclass of Articulator. It is the superclass one or two of the concrete Articulator classes, including Velum.
	%	As an abstract class, ShapeArticulator is never instantiated itself. Instead, instantiate one of its subclasses.
	%
	%	ShapeArticulator Properties:
	%		tau - A parameter for controlling which and how many pixels are used in the Region of Interest.
	%		searchRadius - Conrols the number of pixels beyond the initial one that might be suitable for calculating time series.
	%		pixelMinimum - The minimum number of pixels permitted in the Region of Interest for a ShapeArticulator.
	%
	%	ShapeArticulator Methods
	%		run - Sets most Articulator values; finds both the unfiltered and filtered time series for the Articulator.
	%
	%	See also, VocalTract, Articulator, RadialArticulator, Velum
	
	%	Reed Blaylock July 16, 2014

	properties
		tau				% Determines how strongly correlated points must be to include them in the Region of Interest. Generally set between 0.55 and 0.8.
		searchRadius	% Determines how many possible Regions of Interest will be compared. The number of regions tested equals ((searchRadius * 2) + 1)^2
		pixelMinimum	% Sets the lower bound for the number of pixels that must be in a Region of Interest. Too few points may capture a wider dynamic range, but loses physical accuracy.
	end
	
	methods
		function [] = run(obj,points,vidMatrix,numFrames)
			%	run	Initializes the ShapeArticulatr object
			%		obj.run()				Establishes the uniquely-shaped Region of Interest and calculates its raw and filtered time series.
			%
			%	Input arguments:
			%		obj - A ShapeArticulator object.
			%		points - An Nx2 matrix with the set of points that should be the centers of circular regions for analysis.
			%		vidMatrix - A numFrames x 4624 matrix containing all the intensity values for every pixel at each frame of the rtMR video.
			%		numFrames - The number of frames in the rtMR video.
			%
			%	Example: Running the RadialArticulator object
			%		obj = Velum('myvideo.avi'); % The class 'Velum' is a non-abstract class which subclasses Articulator.
			%		obj.run();
			%
			%	See also VocalTract, ShapeArticulator, Lips, TongueTip, TongueBody, TongueRoot
			
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

