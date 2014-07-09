classdef TongueBody < RadialArticulator
	%TongueTipTimeSeries Contains the methods and properties required for pixel
	%intensity measurements of velum movement
	%   Detailed explanation goes here
	
	methods
		function obj = TongueBody()
			obj.name = 'DOR';
			obj.nameForStorage = 'ts_dor';
			obj.displayName = 'tongue body';
			
			obj.radius = 3;
		end
	end
	
end

