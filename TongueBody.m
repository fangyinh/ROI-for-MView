classdef TongueBody < RadialArticulator
	%	TongueBody Contains Articulator information about the TongueBody
	%   TongueBody is a subclass of RadialArticulator. It uses two points to find the Region of Interest in the area of the tongue body.
	%	
	%	TongueBody Methods:
	%		TongueBody - Constructor method
	%
	%	See also VocalTract, RadialArticulator, Articulator
	
	%	Reed Blaylock July 16, 2014

	methods
		function obj = TongueBody()
			%	TongueBody	Constructor method for the TongueBody class.
			%		obj = TongueBody()				Returns a new TongueBody object. Call the run() method to find time series information.
			%
			%	Output argument:
			%		obj - A TongueBody object.
			%
			%	Example: Invoking the constructor
			%		obj = TongueBody();
			%
			%	See also run, VocalTract/setArticulator
			
			obj.name = 'DOR';
			obj.nameForStorage = 'ts_dor';
			obj.displayName = 'tongue body';
			
			obj.radius = 3;
		end
	end
	
end

