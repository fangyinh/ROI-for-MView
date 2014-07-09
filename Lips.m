classdef Lips < RadialArticulator
	%TongueTipTimeSeries Contains the methods and properties required for pixel
	%intensity measurements of velum movement
	%   Detailed explanation goes here
	
	methods
		function obj = Lips()
			obj.name = 'LAB';
			obj.nameForStorage = 'ts_lab';
			obj.displayName = 'lips';
			
			obj.radius = 3;
		end
	end
	
end

