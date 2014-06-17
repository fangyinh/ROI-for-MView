classdef TongueBodyTimeSeries < ArticulatorTimeSeries
	%TongueTipTimeSeries Contains the methods and properties required for pixel
	%intensity measurements of velum movement
	%   Detailed explanation goes here
	
	properties
		radius
	end
	
	methods
		function obj = TongueBodyTimeSeries()
			obj.name = 'DOR';
			obj.nameForStorage = 'ts_dor';
		end
	end
	
end

