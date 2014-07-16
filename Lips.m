classdef Lips < RadialArticulator
	%	Lips Contains Articulator information about the Lips
	%   Lips is a subclass of RadialArticulator. It uses two points to find the Region of Interest in the area of the lips.
	%	
	%	Lips Methods:
	%		Lips - Constructor method
	%
	%	See also VocalTract, RadialArticulator, Articulator
	
	%	Reed Blaylock July 16, 2014

	methods
		function obj = Lips()
			%	Lips	Constructor method for the Lips class.
			%		obj = Lips()				Returns a new Lips object. Call the run() method to find time series information.
			%
			%	Output argument:
			%		obj - A Lips object.
			%
			%	Example: Invoking the constructor
			%		obj = Lips();
			%
			%	See also run, VocalTract/setArticulator
			
			obj.name = 'LAB';
			obj.nameForStorage = 'ts_lab';
			obj.displayName = 'lips';
			
			obj.radius = 3;
		end
	end
	
end

