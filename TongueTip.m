classdef TongueTip < RadialArticulator
	%TongueTipTimeSeries Contains the methods and properties required for pixel
	%intensity measurements of velum movement
	%   Detailed explanation goes here
	
	methods
		function obj = TongueTip()
			obj.name = 'COR';
			obj.nameForStorage = 'ts_tt';
			obj.displayName = 'tongue tip';
			
			obj.radius = 3;
		end
	end
	
end

