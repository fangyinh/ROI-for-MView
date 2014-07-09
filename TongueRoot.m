classdef TongueRoot < RadialArticulator
	%TongueTipTimeSeries Contains the methods and properties required for pixel
	%intensity measurements of velum movement
	%   Detailed explanation goes here
	
	methods
		function obj = TongueRoot()
			obj.name = 'PHAR';
			obj.nameForStorage = 'ts_root';
			obj.displayName = 'tongue root';
			
			obj.radius = 3;
		end
	end
	
end

