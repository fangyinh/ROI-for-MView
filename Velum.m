classdef Velum < ShapeArticulator
	%VelumTimeSeries Contains the methods and properties required for pixel
	%intensity measurements of velum movement
	%   Detailed explanation goes here
	
	methods
		function obj = Velum()
			obj.name = 'VEL';
			obj.nameForStorage = 'ts_vel';
			obj.displayName = 'velum';
			
			obj.tau = .6;
			obj.pixelMinimum = 5;
			obj.searchRadius = 1;
		end
	end
	
end

