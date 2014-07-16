classdef (Abstract) Articulator < handle
	%	Articulator Superclass for all vocal tract articulator objects.
	%   This class is the foundation for all articulators stored in a VocalTract object. This class is abstract; you will never instantiate it on its own.
	%	The RadialArticulator and ShapeArticulator classes are subclasses of this class.
	% 	
	% 	Articulator Properties:
	%		name - The label for this articulator.
	%		mask - The set of points that describe an articulator.
	%		ts_raw - The unfiltered time series for an articulator.
	%		ts_filt - The filtered time series for an articulator.
	%		x - The x coordinate at the middle of the articulator region.
	%		y - The y coordinate at the middle of the articulator region.
	%		nameForStorage - The name of the file that would contain this Articulator object.
	%		displayName - The string to be used when referring to this object in a message output.
	%	
	%	Articulator Methods:
	%		saveAs - Saves the Articulator object into a .mat file.
	%		filter - Filters the raw time series.
	%		isEmpty - Checks if the Articulator has been initialized with a time series.
	%		run - (abstract) Finds the time series and mask values.
	%
	%	See also VocalTract, RadialArticulator, ShapeArticulator
	
	%	Reed Blaylock July 16, 2014

	properties
		name			% The label for an instantiation of the Articulator class. Set in the constructor.
		mask			% A 68x68 matrix where every point involved in calculating the time series for this articulator is greater than 0.
		ts_raw			% The raw, unfiltered time series. Found by averaging the pixel intensities of certain points across time.
		ts_filt			% The filtered version of the raw time series. Should be used without further filtering.
		x				% The x-coordinate most closely representing the middle of the range of points used for calculating the time series for this articulator.
		y				% The y-coordinate most closely representing the middle of the range of points used for calculating the time series for this articulator.
		nameForStorage	% A string used for saving and loading an Articulator object in a .mat file.
		displayName		% A string that can be used when referring to the Articulator in an output to the user.
	end
	
	methods
		function saveAs(obj, filename)
			%	saveAs	Saves the Articulator object to a .mat file.
			%		obj.saveAs()				Saves this Articulator object to a file. The file name is determined by the value in the nameForStorage property.
			%
			%	This method is deprecated, and will be removed in a future version. (The authors see no reason to save one Articulator when it's so much easier to put all the Articulators in a VocalTract object.)
			%
			%	Input arguments:
			%		obj - An Articulator object.
			%
			%	Example: Saving the Articulator object
			%		obj = Lips('myvideo.avi'); % The class 'Lips' is a non-abstract class which subclasses Articulator.
			%		obj.saveAs();
			%
			%	See also VocalTract
			
			[~, dir, ~] = fileparts(filename);
			if ~exist(dir, 'dir')
				mkdir(dir);
			end
			save(strcat(dir,'/',obj.nameForStorage),'obj');
		end
		
		function [ts_filt] = filter(obj,ts_raw) %#ok<INUSL>
			%	filter	Smooths an Articulator time series.
			%		ts_filt = obj.filter(ts_raw)				Smooth the time series using a locally-weighted linear regression algorithm. Returns the filtered time series.
			%
			%	Input arguments:
			%		obj - An Articulator object.
			%		ts_raw - The unfiltered time series for this Articulator.
			%
			%	Output arguments:
			%		ts_filt - The filtered time series for this Articulator.
			%
			%	Example: Filtering a time series
			%		ts_filt = obj.filter(ts_raw);
			%
			%	See also VocalTract, lwregress, run
			
			disp('Filtering time series...');
			interp = 1; % how many subintervals you want to be considered between each frame
			wwid = .9;
			X	= 1:size(ts_raw(:,1));
			Y	= ts_raw;
			D	= linspace(min(X),max(X),(interp*max(X)))';
			[ts_filt, ~] = lwregress( X',Y,D,wwid, 0 );
		end
		
		function [tf] = isEmpty(obj)
			%	isEmpty	Checks if the Articulator object has been run.
			%		tf = obj.isEmpty()				Checks if the raw time series for this Articulator has been set. Returns true if it has, false if it has not.
			%
			%	Input arguments:
			%		obj - A VocalTract object.
			%
			%	Output arguments
			%		tf - A boolean value. TRUE if the raw time series has not been found, FALSE if it has.
			%
			%	Example: Checking if the Articulator is empty
			%		tf = obj.isEmpty();
			%
			%	See also VocalTract, run
			
			tf = isempty(obj.ts_raw);
		end
	end
	
	methods (Abstract = true)
		% run This method finds the time series for the Articulator.
		% 
		% See also RadialArticulator, ShapeArticulator
		
		run(obj, points, vidMatrix, numFrames);
	end
end

