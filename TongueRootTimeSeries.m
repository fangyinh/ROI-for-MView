classdef TongueRootTimeSeries < ArticulatorTimeSeries
	%TongueTipTimeSeries Contains the methods and properties required for pixel
	%intensity measurements of velum movement
	%   Detailed explanation goes here
	
	properties
		radius
	end
	
	methods
		function obj = TongueRootTimeSeries()
			obj.name = 'PHAR';
			obj.nameForStorage = 'ts_root';
		end
	end
	
end

