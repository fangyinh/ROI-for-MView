classdef VocalTract < handle
	%	VocalTract	Describes properties and behaviors of a vocal tract obtained with rtMRI.
	%   This class provides the tools for simple and quick analysis of vocal tract images from rtMR videos.
	%	Users establish regions in the vocal tract corresponding to major articulators: lips (LAB), tongue tip (TT), tongue body (TB), tongue root (TR) and velum (VEL).
	% 	Region of Interest analysis estimates the constriction degree for each articulator.
	% 	Detailed information about these estimates can be obtained from a GUI like MViewRT.
	% 	
	% 	VocalTract Properties:
	%		LAB - The labial articulator.
	%		TT - The tongue tip articulator.
	%		TB - The tongue body articulator.
	%		TR - The tongue root articulator.
	%		VEL - The velum articulator.
	%		filename - The name of the rtMR .avi file.
	%		nameForStorage - The name of the file that will contain this VocalTract object.
	%	
	%	VocalTract Methods:
	%		VocalTract - Constructor method.
	%		setMidline - Assigns a set of points to be the midline of the vocal tract.
	%		getVidMatrix - Returns the rtMR video as a matrix of pixel intensities.
	%		getNumFrames - Returns the number of frames in the rtMR video.
	%		getFramerate - Returns the framerate of the rtMR video.
	%		getMidline - Returns the midline of the vocal tract.
	%		getMask - Returns an image mask of the regions used by articulators.
	%		getMeanImage - Returns the the mean of the rtMR video as a 2D matrix.
	%		showMeanImage - Displays the mean image of the rtMR video.
	%		getStdImage - Returns the standard deviation of the rtMR video as a 2D matrix.
	%		showStdImage - Displays the standard deviation image of the rtMR video.
	%		showMidline - Displays the midline as a mask over the mean or standard deviation image.
	%		save - Saves this VocalTract object to a file beneath the current directory.
	%		init - Finds the midline of the vocal tract and gets articulator information. Call after invoking the constructor.
	%		setArticulator - Finds the regions and time series for an articulator or set of articulators.
	%		load - (static) Load a VocalTract object into the current workspace.
	%		loadIntoMViewRT - (static) Load the information from a VocalTract object into MViewRT.
	%		convertLabelsForGUI - (static) Parse the appropriate information from a .lab file into a .txt file for use with the rtMRI PDF GUI.
	%
	%	See also Articulator, DynamicProgrammer, mviewRT
	
	%	Reed Blaylock July 16, 2014

	properties
		LAB				% A Lips object
		TT				% A TongueTip object
		TB				% A TongueBody object
		TR				% A TongueRoot object
		VEL				% A Velum object
		filename		% Name of the .avi file for which this vocal tract was constructed
		nameForStorage	% Name that will be used for storing this vocal tract and related files
	end
	
	properties (Access = private)
		vidMatrix		% A matrix of size numFrames*4624 containing the pixel intensity values of every frame in the rtMR video
		numFrames		% The number of frames in the rtMR video
		framerate		% The number of frames per second recorded by the rtMR video
		midline			% An Nx2 matrix listing the points on the midline path
		mask			% A 68x68 matrix in which the mask points are > 0.0
	end
	
	methods
		function [obj] = VocalTract(filename, midline)
			%	VocalTract	Constructor method for the VocalTract class.
			%		obj = VocalTract(filename)				Returns a new VocalTract object. Values must be set by calling obj.init().
			%		obj = VocalTract(filename, midline)		Returns a new VocalTract object with a user-defined midline. Values must be set by calling obj.setArticulator().
			%
			%	Input arguments:
			%		filename - The name of the .avi file containing the rtMR video. Can be given with or without the .avi extension.
			%		midline - (optional) An Nx2 matrix of x/y coordinates representing the midline of the vocal tract for this rtMR video.
			%
			%	Output arguments:
			%		obj - A VocalTract object.
			%
			%	Example: Invoking the constructor
			%		obj = VocalTract('myvideo.avi');
			%
			%	See also init, setArticulator, save, load
			
			if nargin > 1
				obj.midline = midline;
			end
			
			obj.filename = filename;
			[~, name, ~] = fileparts(obj.filename);
			obj.nameForStorage = strcat(name,'_vt');
			
			vr = VideoReader(filename);
			obj.numFrames = vr.NumberOfFrames;
			obj.framerate = vr.FrameRate;
			obj.vidMatrix = obj.vr2Matrix(vr);
			
			obj.LAB = Lips();
			obj.TT = TongueTip();
			obj.TB = TongueBody();
			obj.TR = TongueRoot();
			obj.VEL = Velum();
		end
		
		function [] = setMidline(obj, midline)
			%	setMidline	Sets the midline for this vocal tract.
			%		obj.setMidline(midline)				Assigns the submitted midline to this rtMR video.
			%
			%	Input arguments:
			%		obj - A VocalTract object.
			%		midline - An Nx2 matrix of x/y coordinates representing the midline of the vocal tract for an rtMR video.
			%
			%	Example: Setting the midline
			%		obj = VocalTract('myvideo.avi');
			%		obj.setMidline(new_midline);
			%
			%	See also VocalTract, getMidline, showMidline
			
			obj.midline = midline;
		end
		
		function [vidMatrix] = getVidMatrix(obj)
			%	getVidMatrix	Returns the matrix representing the rtMR video.
			%		vidMatrix = obj.getVidMatrix()				Returns a matrix for this VocalTract object.
			%
			%	Input arguments:
			%		obj - A VocalTract object.
			%
			%	Output arguments:
			%		vidMatrix - A matrix of size numFrames x 4624 containing the pixel intensity values in every frame in the rtMR video.
			%
			%	Example: Retrieving the vidMatrix
			%		obj = VocalTract('myvideo.avi');
			%		vidMatrix = obj.getVidMatrix();
			%
			%	See also VocalTract
			
			vidMatrix = obj.vidMatrix;
		end
		
		function [numFrames] = getNumFrames(obj)
			%	getNumFrames	Returns the number of frames in this rtMR video.
			%		vidMatrix = obj.getVidMatrix()				Returns the number of frames in this rtMR video.
			%
			%	Input arguments:
			%		obj - A VocalTract object.
			%
			%	Output arguments:
			%		numFrames - An integer specifying the number of frames in this video.
			%
			%	Example: Retrieving the number of frames
			%		obj = VocalTract('myvideo.avi');
			%		numFrames = obj.getNumFrames();
			%
			%	See also VocalTract
			
			numFrames = obj.numFrames;
		end
		
		function [framerate] = getFramerate(obj)
			%	getFramerate	Returns the framerate the rtMR video.
			%		framerate = obj.getFramerate()				Returns the number of frames per second in this rtMR video.
			%
			%	Input arguments:
			%		obj - A VocalTract object.
			%
			%	Output arguments:
			%		framerate - An double specifying how many image frames were captured in one second.
			%
			%	Example: Retrieving the framerate
			%		obj = VocalTract('myvideo.avi');
			%		framerate = obj.getFramerate();
			%
			%	See also VocalTract
			
			framerate = obj.framerate;
		end
		
		function [midline] = getMidline(obj)
			%	getMidline	Returns the midline of the vocal tract.
			%		midline = obj.getVidMatrix()				Returns the midline of the the vocal tract as a set of points. If the midline has not been set, returns an empty matrix.
			%
			%	Input arguments:
			%		obj - A VocalTract object.
			%
			%	Output arguments:
			%		midline - An N*2 matrix of x/y coordinates representing the midline through the vocal tract in this rtMR video.
			%
			%	Example: Retrieving the midline
			%		obj = VocalTract('myvideo.avi');
			%		obj.init();
			%		midline = obj.getMidline();
			%
			%	See also VocalTract, init, showMidline, setMidline
			
			if isempty(obj.midline)
				disp('ERROR: You cannot access the vocal tract midline before calling the getVocalTract() method on your VocalTract object.');
				midline = [];
				return;
			end
			midline = obj.midline;
		end
		
		function [mask] = getMask(obj)
			%	getMask	Returns an image mask of the regions of interest.
			%		mask = obj.getMask()				Returns a mask of all the points used in the Region of Interest analysis for this vocal tract. If a mask has not been set, returns an empty matrix.
			%
			%	Input arguments:
			%		obj - A VocalTract object.
			%
			%	Output arguments:
			%		mask - A 68x68 matrix. Points in regions of interest have a value greater than 0.0; all others are 0.0. Empty if no mask has been set.
			%
			%	Example: Retrieving the mask
			%		obj = VocalTract('myvideo.avi');
			%		obj.init();
			%		mask = obj.getMask();
			%
			%	See also VocalTract, Articulator
			
			if isempty(obj.midline)
				disp('ERROR: You cannot access the vocal tract mask before calling the getVocalTract() method on your VocalTract object.');
				mask = [];
				return;
			end
			mask = obj.mask;
		end
		
		function [meanImage] = getMeanImage(obj)
			%	getMeanImage	Returns the mean of the rtMR video as a single image.
			%		meanImage = obj.getMeanImage()				Returns a matrix for representing the average intensity for each pixel in the rtMR video.
			%
			%	Input arguments:
			%		obj - A VocalTract object.
			%
			%	Output arguments:
			%		meanImage - A 68x68 matrix containing the average intensity for each pixel over all frames.
			%
			%	Example: Retrieving the mean image
			%		obj = VocalTract('myvideo.avi');
			%		meanImage = obj.getMeanImage();
			%
			%	See also VocalTract, showMeanImage, getStdImage
			
			meanImage = reshape(mean(obj.vidMatrix,1),68,68);
		end
		
		function [] = showMeanImage(obj)
			%	showMeanImage	Displays the mean vocal tract image in a new figure.
			%		obj.showMeanImage()				Returns nothing. Displays the mean image in a figure.
			%
			%	Input arguments:
			%		obj - A VocalTract object.
			%
			%	Example: Displaying the mean image
			%		obj = VocalTract('myvideo.avi');
			%		obj.showMeanImage();
			%
			%	See also VocalTract, getMeanImage, showStdImage
			
			meanImage = obj.getMeanImage();
			imagesc(meanImage);
			colormap gray;
		end
		
		function [stdImage] = getStdImage(obj)
			%	getStdImage	Returns the standard deviation of the rtMR video in a single image.
			%		stdImage = obj.getStdImage()				Returns a matrix representing the standard deviation of each pixel in the rtMR video.
			%
			%	Input arguments:
			%		obj - A VocalTract object.
			%
			%	Output arguments:
			%		stdImage - A 68x68 matrix containing the standard deviation of pixel intensity values over every frame in the rtMR video. Brighter pixels show a wider range of intensity values in the course of the video than darker pixels.
			%
			%	Example: Retrieving the standard deviation image
			%		obj = VocalTract('myvideo.avi');
			%		stdImage = obj.getStdImage();
			%
			%	See also VocalTract, showStdImage, getMeanImage
			
			stdImage = reshape(std(obj.vidMatrix,1),68,68);
		end
		
		function [] = showStdImage(obj)
			%	showStdImage	Displays the standard deviation of the rtMR video as an image.
			%		obj.showStdImage()				Returns nothing. Opens the standard deviation image in a figure. Brighter pixels have a wider range of intensity values during the course of the video.
			%
			%	Input arguments:
			%		obj - A VocalTract object.
			%
			%	Example: Displaying the standard deviation image
			%		obj = VocalTract('myvideo.avi');
			%		obj.showStdImage();
			%
			%	See also VocalTract, getStdImage, showMeanImage
			
			stdImage = obj.getStdImage();
			imagesc(stdImage);
			colormap gray;
		end
		
		function [] = showMidline(obj, imgType)
			%	showMidline	Displays the midline of the vocal tract as a mask on the mean or standard deviation image.
			%		obj.showMidline()				Displays the vocal tract midline as a mask over the mean image.
			%
			%	Input arguments:
			%		obj - A VocalTract object.
			%		imgType - (optional) Specifies whether the mask should appear on the mean image ('mean') or standard deviation image ('std').
			%
			%	Example: Displaying the midline on the mean image
			%		obj = VocalTract('myvideo.avi');
			%		obj.init();
			%		obj.showMidline(); % or, obj.showMidline('mean');
			%
			%	Example: Displaying the midline on the standard deviation
			%		obj = VocalTract('myvideo.avi');
			%		obj.init();
			%		obj.showMidline('std');
			%
			%	See also VocalTract, init, getMidline, setMidline, showMeanImage, showStdImage
			
			if isempty(obj.midline)
				disp('ERROR: You cannot access the vocal tract midline before calling the getVocalTract() method on your VocalTract object.');
				return;
			end
			
			if nargin < 2
				imgType = 'mean';
			end
			
			switch imgType
				case 'mean'
					image = obj.getMeanImage();
				case 'std'
					image = obj.getStdImage();
				otherwise
					disp('The image type must be either "mean" for a mean image or "std" for a standard deviation image. Showing the masked mean image now.');
					image = obj.getMeanImage();
			end
			
			mask = obj.shapeMidline(); %#ok<PROP>
			
			maskedImage = image + (2 * (mask ./ max(max(mask)))); %#ok<PROP>
			imagesc(maskedImage);
			colormap gray;
		end
		
		function [] = save(obj)
			%	save	Saves the VocalTract object to a .mat file.
			%		obj.save()				Saves this VocalTract object to a file. The file name is determined by the value in the nameForStorage property.
			%
			%	Input arguments:
			%		obj - A VocalTract object.
			%
			%	Example: Saving the VocalTract object
			%		obj = VocalTract('myvideo.avi');
			%		obj.save();
			%
			%	See also VocalTract, load, loadIntoMViewRT
			
			save(obj.nameForStorage, 'obj');
			
% 			[~, dir, ~] = fileparts(obj.filename);
% 			if ~exist(dir, 'dir')
% 				mkdir(dir);
% 			end
% 			save(strcat(dir,'/',obj.nameForStorage),'obj');
		end
		
		function [startPoint, midPoint, endPoint] = init(obj)
			%	init	Initializes the VocalTract object.
			%		[startPoint, midPoint, endPoint] = obj.init()				Returns the x/y coordinates of the three user-defined points used for finding the midline.
			%
			%	Call this function after invoking the VocalTract constructor. Do not use this function if you have given the VocalTract object a pre-specified midline (instead, use setArticulator).
			%
			%	Input arguments:
			%		obj - A VocalTract object.
			%
			%	Output arguments:
			%		startPoint - A 1x2 matrix containing the x/y coordinates of the first point selected
			%		midPoint - A 1x2 matrix containing the x/y coordinates of the second point selected
			%		endPoint - A 1x2 matrix containing the x/y coordinates of the third point selected
			%
			%	Example: Initializing the VocalTract object
			%		obj = VocalTract('myvideo.avi');
			%		obj.init();
			%
			%	See also VocalTract, DynamicProgrammer, setArticulator, setMidline
			
			figure('name','Select anchor points');
			obj.showStdImage();
			
			[startX, startY] = obj.getPointFromClick('Click at the front of the lower lip.');
			[midX, midY] = obj.getPointFromClick('Click at the back of the tongue body.');
			[endX, endY] = obj.getPointFromClick('Click at the larynx.');
			
			close('Select anchor points');
			
			startPoint = [startX, startY];
			midPoint = [midX, midY];
			endPoint = [endX, endY];
			
			dp = DynamicProgrammer();
			dp.setImage(obj.getStdImage());
			obj.midline = dp.findPath([startPoint; midPoint; endPoint]);
			
			obj.setArticulator({'LAB', 'TT', 'TB', 'TR', 'VEL'});
			
			obj.save();
		end
		
		function [] = setArticulator(obj, articulatorNames)
			%	setArticulator	Sets the values for the specified Articulator objects in the VocalTract.
			%		obj.setArticulator(articulatorNames)				Finds and stores a time series for each of the articulators in articulatorNames.
			%
			%	This function is called automatically by init(). Call this function explicitly when you have supplied the VocalTract with a pre-defined midline, or if you want to change the values of some Articulator.
			%
			%	Input arguments:
			%		obj - A VocalTract object.
			%		articulatorNames - A 1xN cell array containing the names, as strings, of the Articulators. Use 'LAB' for Lips, 'TT' TongueTip, 'TB' for TongueBody, 'TR' for TongueRoot, and 'VEL' for Velum.
			%
			%	Example: Initializing the vocal tract with a pre-defined midline
			%		obj = VocalTract('myvideo.avi', midline);
			%		obj.setArticulator({'LAB','TT','TB','TR','VEL'});
			%
			%	Example: Changing the values of the TongueTip
			%		obj = VocalTract.load('myvideo.avi');
			%		obj.setArticulator({'TT'});
			%
			%	See also VocalTract, init, load
			
			if isempty(obj.midline)
				disp('WARNING: A midline has not been set. Each gesture will be extracted from a single circular region.');
			end
			if ismember('LAB', articulatorNames)
				obj.extractArticulator(obj.LAB);
			end
			if ismember('TT', articulatorNames)
				obj.extractArticulator(obj.TT);
			end
			if ismember('TB', articulatorNames)
				obj.extractArticulator(obj.TB);
			end
			if ismember('TR', articulatorNames)
				obj.extractArticulator(obj.TR);
			end
			if ismember('VEL', articulatorNames)
				obj.extractArticulator(obj.VEL);
			end
		end
	end
	
	methods (Access = private)
		function [x, y] = getPointFromClick(obj, message) %#ok<INUSL>
			%	getPointFromClick	(private) Returns the x/y coordinate of a pixel the user clicked on.
			%		[x, y] = obj.getPointFromClick()				Returns the x and y coordinates of the point that was clicked.
			%
			%	This method is meant only to assist public VocalTract functions. You may not call it in isolation.
			%
			%	Input arguments:
			%		obj - A VocalTract object.
			%		message - (optional) A message to display to the user when expecting a click.
			%
			%	Output arguments:
			%		x - The x-coordinate of the clicked point (technically a 1x1 column vector).
			%		y - The y-coordinate of the clicked point (technically a 1x1 column vector).
			%
			%	Example: Retrieving the vidMatrix
			%		obj = VocalTract('myvideo.avi');
			%		obj.showStdImage();
			%		[x, y] = obj.getPointFromClick();
			%
			%	See also VocalTract, showMidline, showMeanImage, showStdImage, ginput
			
			if nargin > 1
				disp(message);
			end
			
			[raw_x, raw_y] = ginput(1);
			x = round(raw_x);
			y = round(raw_y);
		end
		
		function [] = extractArticulator(obj, articulator)
			%	extractArticulator	(private) Sets the values for the specified articulator.
			%		obj.extractArticulator(articulator)				Sets the values of one articulator.
			%
			%	This method is meant only to assist public VocalTract functions. You may not call it in isolation.
			%
			%	Input arguments:
			%		obj - A VocalTract object.
			%		articulator - A string containing the label of one articulator (i.e. 'LAB' for Lips; see setArticulator for more details).
			%
			%	Example: Extracting the TongueTip Articulator from the vocal tract image
			%		obj = VocalTract('myvideo.avi');
			%		obj.extractArticulator('TT');
			%
			%	See also VocalTract, Articulator, setArticulator
			
			figure('name',['Extract the ',articulator.displayName]);
			
			
			if ~articulator.isEmpty()
				disp(['WARNING: You are about to overwrite previous data for the ' articulator.displayName '. If you close the figure window or quit this script now, your data will not be overwritten.']);
			end
			
			if isa(articulator, 'Velum')
				obj.showMeanImage();
				
				[x, y] = obj.getPointFromClick(['Click at the top of the ' articulator.displayName '.']);
				articulator.run([x y], obj.vidMatrix, obj.numFrames);
			else
				if ~isempty(obj.midline)
					obj.showMidline('mean');
					
					[frontX, frontY] = obj.getPointFromClick(['Click the point on the path that is closest to the front of the ' articulator.displayName '.']);
					tempPath = [frontX frontY; obj.midline];
					D = squareform(pdist(tempPath));
					[~, iFront] = min(D(1,2:end));

					[backX, backY] = obj.getPointFromClick(['Click the point on the path that is closest to the back of the ' articulator.displayName '.']);
					tempPath = [backX backY; obj.midline];
					D = squareform(pdist(tempPath));
					[~, iBack] = min(D(1,2:end));
					
					articulator.run(obj.midline(iFront:iBack,:), obj.vidMatrix, obj.numFrames);
				else
					obj.showMeanImage();
					
					[oX, oY] = obj.getPointFromClick(['Click at the ' articulator.displayName '.']);
					articulator.run([oX, oY], obj.vidMatrix, obj.numFrames);
				end
			end
			close(['Extract the ',articulator.displayName]);
		end
		
		function [mask] = shapeMidline(obj)
			%	shapeMidline	(private) Returns the midline of the vocal tract as an image mask.
			%		mask = obj.shapeMidline()				Shapes the VocalTract object's midline into a matrix that can be used as an image mask.
			%
			%	This method is meant only to assist public VocalTract functions. You may not call it in isolation.
			%
			%	Input arguments:
			%		obj - A VocalTract object.
			%
			%	Output arguments:
			%		mask - A 68x68 matrix. Coordinates on the midline are greater than 500.0; all others are 0.
			%
			%	Example: Shaping the midline
			%		obj = VocalTract('myvideo.avi');
			%		obj.init();
			%		mask = obj.shapeMidline();
			%
			%	See also VocalTract, showMidline, setMidline
			
			mask = zeros(68, 68);
			for r = 1:size(obj.midline,1)
				mask(obj.midline(r,2), obj.midline(r,1)) = 1;
			end
			mask = mask * 500;
		end
		
		function [M] = vr2Matrix(obj, vr)
% 			
% 			Adam Lammert (2010)
% 			Modified by Reed Blaylock (2014) to make compatible with VideoReader and
% 			to consolidate code
% 			
% 			Convert Avi file to Matrix of Frames
% 			
% 			INPUT 
% 			  vr: VideoReader object
% 			OUTPUT
% 			  M: the normalized movie matrix 
% 			      (rows are frames, columns are linearly indexed pixels)

			% Get data from VideoReader
			vidFrames = read(vr);

			% Convert VideoReader output to something usable
			for k = 1 : obj.numFrames
				mov(k).cdata = vidFrames(:,:,:,k); %#ok<AGROW>
				mov(k).colormap = []; %#ok<AGROW>
			end

			% Get movie information
			frame_height = vr.Height;
			frame_width = vr.Width;
			vec_length = frame_height*frame_width;

			% Reshape matrix
			M = zeros(obj.numFrames,vec_length);
			for itor = 1:obj.numFrames
				M(itor,:) = reshape(double(mov(itor).cdata(:,:,1)),1,vec_length);
			end

			% Normalize matrix
			M = M./repmat(mean(M,2),1,size(M,2));
		end
		
		function [avgSlopes] = findSlopes(obj)
			% Returns an average of the slope of a line measured at each point in the midline
			diffs = diff(obj.midline);
			slopes = zeros(length(diffs),1);
			for i = 1:length(diffs)
				slopes(i) = diffs(i,2)/diffs(i,1);
			end
			
			avgSlopes = zeros(length(obj.midline),1);
			avgSlopes(1) = slopes(1);
			
			for i = 2:length(slopes)
				avgSlopes(i) = mean([slopes(i-1), slopes(i)]);
			end
			
			avgSlopes(length(obj.midline)) = slopes(length(slopes));
		end
	end
	
	methods (Static)
		function [obj] = load(filename)
			%	load	(static) Loads a VocalTract object from a .mat file into the current workspace.
			%		[obj] = VocalTract.load(filename)				Returns a VocalTract object.
			%
			%	Input arguments:
			%		filename - A string containing the name of an rtMR video (.avi file).
			%
			%	Output arguments:
			%		obj - A VocalTract object that had previously been constructed for the .avi file corresponding to the filename parameter.
			%
			%	Example: Loading a VocalTract object
			%		obj = VocalTract.load('myvideo.avi');
			%
			%	See also VocalTract, save, loadIntoMViewRT
			
			no_ext = isempty(strfind(filename, '.avi'));
			if ~no_ext
			% 	filename came with an extension. Get rid of it.
				[~, filename, ~] = fileparts(filename);
			end
			file = load(strcat(filename,'_vt.mat'));
% 			file = load(strcat([filename '/' filename '_vt.mat']));
			obj = file.obj;
		end
		
		function [] = loadIntoMViewRT(filename)
			%	loadIntoMViewRT	(static) Loads a VocalTract object from a .mat file into the MViewRT GUI.
			%		VocalTract.loadIntoMViewRT(filename)				Opens MViewRT with information from all of the non-empty Articulators set in the VocalTract object.
			%
			%	Input arguments:
			%		filename - A string containing the name of an rtMR video (.avi file).
			%
			%	Example: Loading time series into MViewRT
			%		VocalTract.loadIntoMViewRT('myvideo.avi');
			%
			%	See also VocalTract, save, load, convertLabelsForGUI
			
			no_ext = isempty(strfind(filename, '.avi'));
			if ~no_ext
			% 	filename came with an extension. Get rid of it.
				[~, filename, ~] = fileparts(filename);
			end
			
			obj = VocalTract.load(filename);
			
			data.fps = obj.framerate;
			
			frames = 0:(obj.numFrames-1); % 1 gets added in FormatData.m, so subtract it here (assuming the frames are 1-based instead of 0-based, I suppose)
			times = frames ./ obj.framerate;

			articulators = {'LAB', 'TT', 'TB', 'TR', 'VEL'};
			
			n = 1;
			for k = 1:numel(articulators)
				str = articulators{k};
				articulator = obj.(str);
				
				if ~articulator.isEmpty()
					data.gest(n).name = articulator.name;
					data.gest(n).location = [articulator.x, articulator.y];

					data.gest(n).frames = frames;
					data.gest(n).times = times;

					data.gest(n).Ismoothed = articulator.ts_filt;
					data.gest(n).stimes = times;
					
					n = n + 1;
				end
			end
			
			dataForMView = FormatData(data, filename); % This function should be with the other MViewRT functions

			mviewRT(dataForMView, 'LPROC', 'lp_findgest');
		end
		
		function [] = convertLabelsForGUI(filename)
			%	convertLabelsForGUI	Creates a new .txt file with gesture labels in a format that the rtMRI PDF GUI can handle.
			%		VocalTract.convertLabelsForGUI(filename)				Formats the 'COMMENT' and 'MAXC (ms)' values from an MViewRT .lab file into something readable by the rtMRI PDF GUI.
			%
			%	Input arguments:
			%		filename - A string containing the name of a set of gesture labels (.lab file).
			%
			%	Example: Preparing labels for the GUI
			%		VocalTract.convertLabelsForGUI('myvideo.lab');
			%
			%	See also VocalTract, save, loadIntoMViewRT
			
			[~, name, ~] = fileparts(filename);
			filename = strcat(name, '.lab');
			obj = VocalTract.load(name);
			fps = obj.framerate;
			
			if ~exist(filename, 'file') == 2
				disp(['ERROR: There is no file with the name ' filename]);
				return;
			end
			
			data = importdata(filename);
			labels = data.textdata(2:end,3);
			peaks = data.textdata(2:end,7);
			
			m_peaks = str2double(peaks);
			f_peaks = round((m_peaks / 1000) * fps);
			n = length(f_peaks);
			n_peaks = cell(n,1);
			for i = 1:n
				n_peaks{i} = sprintf('%i',f_peaks(i));
			end
			
			arr = cell(size(labels,1),2);
			for i = 1:size(labels,1)
				arr{i,1} = labels{i,1};
				arr{i,2} = n_peaks{i,1};
			end
			
			cell2csv(strcat(name,'.txt'),arr,' ');
		end
	end
	
end

