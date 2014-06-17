classdef LabialTimeSeries < ArticulatorTimeSeries
	%TongueTipTimeSeries Contains the methods and properties required for pixel
	%intensity measurements of velum movement
	%   Detailed explanation goes here
	
	properties
		radius
	end
	
	methods
		function obj = LabialTimeSeries()
			obj.name = 'LAB';
			obj.nameForStorage = 'ts_lab';
		end
	end
	
end

