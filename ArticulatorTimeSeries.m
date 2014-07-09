classdef (Abstract) ArticulatorTimeSeries
	%VelumTimeSeries Contains the methods and properties required for pixel
	%intensity measurements of velum movement
	%   Detailed explanation goes here
	
	properties
		name
		framerate
		vidMatrix
		meanImage
		maskedImage
		mask
		ts_cra
		ts_filt
		x
		y
		nameForStorage
	end
	
	methods
		function saveAs(obj, filename)
			% Create directory
			[~, dir, ~] = fileparts(filename);
			if ~exist(dir, 'dir')
				mkdir(dir);
			end
			save(strcat(dir,'/',obj.nameForStorage),'obj');
		end
	end
	
end

