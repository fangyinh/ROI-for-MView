classdef (Abstract) RadialArticulator < Articulator
	%	RadialArticulator Abstract subclass of Articulator
	%   RadialArticulator is a subclass of Articulator. It is the superclass of most concrete Articulator classes, including Lips, TongueTip, TongueBody, and TongueRoot.
	%	As an abstract class, RadialArticulator is never instantiated itself. Instead, instantiate one of its subclasses.
	%
	%	RadialArticulator Properties:
	%		radius - The number of points out from the center of a circular region to be used when finding an Articulator time series.
	%		points - The set of origin points for the circular regions used to find the Articulator time series.
	%
	%	RadialArticulator Methods
	%		run - Sets most Articulator values; finds both the unfiltered and filtered time series for the Articulator.
	%
	%	See also, VocalTract, Articulator, ShapeArticulator, Lips, TongueTip, TongueBody, TongueRoot
	
	%	Reed Blaylock July 16, 2014
	
	properties
		radius	% The length of the radius of the circular region used for defining the time series of an Articulator
		points	% The set of points to be used as the origin of the circular Regions of Interest
	end
	
	methods	
		function [] = run(obj, points, vidMatrix, numFrames)
			%	run	Initializes the RadialArticulatr object
			%		obj.run()				Establishes the circular Region of Interest and calculates its raw and filtered time series.
			%
			%	Input arguments:
			%		obj - A RadialArticulator object.
			%		points - An Nx2 matrix with the set of points that should be the centers of circular regions for analysis.
			%		vidMatrix - A numFrames x 4624 matrix containing all the intensity values for every pixel at each frame of the rtMR video.
			%		numFrames - The number of frames in the rtMR video.
			%
			%	Example: Running the RadialArticulator object
			%		obj = Lips('myvideo.avi'); % The class 'Lips' is a non-abstract class which subclasses Articulator.
			%		obj.run();
			%
			%	See also VocalTract, ShapeArticulator, Lips, TongueTip, TongueBody, TongueRoot
			
			numPoints = size(points,1);
			regionTS = zeros(numFrames, numPoints);
			artMask = zeros(68, 68);
			
			for k = 1:numPoints
				rx = points(k, 1);
				ry = points(k, 2);
				[ts_cra_xy, mask_xy] = obj.findTimeSeries(vidMatrix,[ry rx]);
				regionTS(:,k) = ts_cra_xy;
				artMask = artMask + mask_xy;
			end
			
			avgTS = mean(regionTS,2);
			
% 			Flip the time series so that constrictions happen at local minima
% 			(this is how MViewRT works)
			avgTS = max(avgTS) - avgTS + min(avgTS);
			
			obj.points = points;
			obj.ts_raw = avgTS;
			obj.ts_filt = obj.filter(avgTS);
			obj.mask = artMask;
			
			m = ceil(numPoints/2);
			
			obj.x = points(m,1);
			obj.y = points(m,2);
		end
	end
	
	methods (Access = protected)
		function [ts_raw, mask] = findTimeSeries(obj, vidMatrix, pixloc)
% 			
% 			Adam Lammert (2010)
% 			
% 			Correlated Region Analysis with Manual Selection
% 			
% 			INPUTS:
% 			  filename: file name of .avi movie
% 			  t: region radius
% 			  pixloc: seed pixel location [y x]
% 			OUTPUTS:
% 			  ts: time series corresp. to the Correlated Region
% 			  R: image mask corresp. to the Correlated Region
% 			  

			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% DETERMINE THE REGION
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			fheight = 68;
			fwidth = 68;
			
			% Neighbors
			[N] = obj.pixelneighbors([fheight fwidth],pixloc(1),pixloc(2));

			%iteratively determine the region
			mask = zeros(68,68);
			for itor = 1:size(N,1)
				mask(N(itor,1),N(itor,2)) = 1;
			end

			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% DETERMINE THE TIME SERIES
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			ts_raw = mean(vidMatrix(:,mask>0),2);
		end
		
		function [N] = pixelneighbors(obj, siz,i,j)
% 			
% 			Adam Lammert (2010)
% 			
% 			Determine the neighbors to an pixel (using subscripts)
% 			
% 			INPUT
% 			   siz : size of the image (i.e., [height width])
% 			   i : the input height subscript
% 			   j : the input width subscript
% 			   h : neighborhood size (circum.)
% 			
% 			OUTPUT
% 			   N : a matrix of neighbor subscripts
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
			D = zeros(fheight,fwidth); %#ok<NASGU>
			D1 = repmat((1:siz(1))',1,siz(2));
			D2 = repmat((1:siz(2)),siz(2),1);
			E1 = repmat(i,68,68);
			E2 = repmat(j,68,68);
			D = sqrt((D1-E1).^2+(D2-E2).^2);

			%Pixels Less than Maximum Distance
			ind = find(D <= obj.radius);
			[y, x] = ind2sub(siz,ind);

			%Build Output
			N = [y x];
		end
	end
	
end

