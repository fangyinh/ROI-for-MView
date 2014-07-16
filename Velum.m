classdef Velum < ShapeArticulator
	%	Velum Contains Articulator information about the velum
	%   Velum is a subclass of ShapeArticulator. It takes a single point and tries to find a velum-shaped region from which to take a time series.
	%	
	%	Velum Methods:
	%		Velum - Constructor method
	%
	%	See also VocalTract, ShapeArticulator, Articulator
	
	%	Reed Blaylock July 16, 2014

	methods
		function obj = Velum()
			%	Velum	Constructor method for the Velum class.
			%		obj = Velum()				Returns a new Velum object. Call the run() method to find time series information.
			%
			%	Output argument:
			%		obj - A Velum object.
			%
			%	Example: Invoking the constructor
			%		obj = Velum();
			%
			%	See also run, VocalTract/setArticulator
			
			obj.name = 'VEL';
			obj.nameForStorage = 'ts_vel';
			obj.displayName = 'velum';
			
			obj.tau = .6;
			obj.pixelMinimum = 5;
			obj.searchRadius = 1;
		end
	end
	
end

