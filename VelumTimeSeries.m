classdef VelumTimeSeries < ArticulatorTimeSeries
	%VelumTimeSeries Contains the methods and properties required for pixel
	%intensity measurements of velum movement
	%   Detailed explanation goes here
	
	properties
% 		name = 'VEL';
		tau
	end
	
	methods
		function obj = VelumTimeSeries()
			obj.name = 'VEL';
			obj.nameForStorage = 'ts_vel';
		end
	end
	
end

