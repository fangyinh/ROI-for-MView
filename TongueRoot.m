classdef TongueRoot < RadialArticulator
	%	TongueRoot Contains Articulator information about the TongueRoot
	%   TongueRoot is a subclass of RadialArticulator. It uses two points to find the Region of Interest in the area of the tongue root.
	%	
	%	TongueRoot Methods:
	%		TongueRoot - Constructor method
	%
	%	See also VocalTract, RadialArticulator, Articulator
	
	%	Reed Blaylock July 16, 2014

	methods
		function obj = TongueRoot()
			%	TongueRoot	Constructor method for the TongueRoot class.
			%		obj = TongueRoot()				Returns a new TongueRoot object. Call the run() method to find time series information.
			%
			%	Output argument:
			%		obj - A TongueRoot object.
			%
			%	Example: Invoking the constructor
			%		obj = TongueRoot();
			%
			%	See also run, VocalTract/setArticulator
			
			obj.name = 'PHAR';
			obj.nameForStorage = 'ts_root';
			obj.displayName = 'tongue root';
			
			obj.radius = 3;
		end
	end
	
end

