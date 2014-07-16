classdef TongueTip < RadialArticulator
	%	TongueTip Contains Articulator information about the TongueTip
	%   TongueTip is a subclass of RadialArticulator. It uses two points to find the Region of Interest in the area of the tongue tip.
	%	
	%	TongueTip Methods:
	%		TongueTip - Constructor method
	%
	%	See also VocalTract, RadialArticulator, Articulator
	
	%	Reed Blaylock July 16, 2014

	methods
		function obj = TongueTip()
			%	TongueTip	Constructor method for the TongueTip class.
			%		obj = TongueTip()				Returns a new TongueTip object. Call the run() method to find time series information.
			%
			%	Output argument:
			%		obj - A TongueTip object.
			%
			%	Example: Invoking the constructor
			%		obj = TongueTip();
			%
			%	See also run, VocalTract/setArticulator
			
			obj.name = 'COR';
			obj.nameForStorage = 'ts_tt';
			obj.displayName = 'tongue tip';
			
			obj.radius = 3;
		end
	end
	
end

