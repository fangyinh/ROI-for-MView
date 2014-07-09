classdef (Abstract) Articulator < handle
	%VelumTimeSeries Contains the methods and properties required for pixel
	%intensity measurements of velum movement
	%   Detailed explanation goes here
	
%	Filtering depends on the file lwregress.m
	
	properties
		name
		mask
		ts_raw
		ts_filt
		x
		y
		nameForStorage
		displayName
	end
	
	methods
		function saveAs(obj, filename)
			[~, dir, ~] = fileparts(filename);
			if ~exist(dir, 'dir')
				mkdir(dir);
			end
			save(strcat(dir,'/',obj.nameForStorage),'obj');
		end
		
		function [ts_filt] = filter(obj,ts_raw) %#ok<INUSL>
			disp('Filtering time series...');
			interp = 1; % how many subintervals you want to be considered between each frame
			wwid = .9;
			X	= 1:size(ts_raw(:,1));
			Y	= ts_raw;
			D	= linspace(min(X),max(X),(interp*max(X)))';
			[ts_filt, ~] = lwregress( X',Y,D,wwid, 0 );
		end
		
		function [tf] = isEmpty(obj)
			tf = isempty(obj.ts_raw);
		end
	end
	
	methods (Abstract = true)
		run(obj, points, vidMatrix, numFrames);
	end
end

