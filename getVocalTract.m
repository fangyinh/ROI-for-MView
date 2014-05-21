function [ ] = getVocalTract( filename )
%	getVocalTract
%	Finds the middle-of-the-vocal-tract points that can be used for RoI
%	analysis.
%	filename -- the name of the video you want to analyze. Include '.avi'
%					extension
% 
% 	HOW TO USE THIS FILE
%	Type onto the command line:
% 		>> getVocalTract(filename)
%	where 'filename' is the name of the movie you want to analyze (e.g.
%	'tonguesarecool.avi'. Make sure to include the file extension in the
%	name.
%	Click on the brightest point of the lower lip. Then click on the
%	brightest point of the tongue tip (or whichever point of the tongue tip
%	you want the path to end on).
%	The path will be overlaid on the standard deviation for your inspection
%	and approval. Save it, delete it, do whatever you want.
% 	
%	HOW THIS FUNCTION WORKS
%   This script uses dynamic programming to find the brightest path between
%   a user-specified start point (i.e. the lower lip) and an end point (i.e. the tongue
%   tip). Bright pixels undergo the largest amount of intensity change
%   during the course of the video, as articulators move in and out of
%   those areas. The brightest pixels have the most change, and are
%   therefore assumed to represent the midpoint for an articulator's
%   movement. Regions of Interest placed along this midline should provide
%   good time series.
% 
%	This algorithm enforces movement in a rightward direction, with
%	optional concurrent movement up or down. For a given point [x,y],
%	reasonable paths are limited to [x+1,y+1] (right and down), [x+1,y]
%	(right), and [x+1,y-1] (right and up).
% 
% 	Paths are also constrained by a bounding box, outside of which no path
% 	may go. The left and right edges of this box are the x-coordinates of
% 	the start and end points; The top and bottom edges are the
% 	y-coordinates of the start and end points.
% 
% 	LIMITATIONS
% 	The bounding box between start and end points has limited height. If
% 	the start and end points have the same y value (same height in the
% 	picture), then the "best path" will always be a straight line. This can
% 	be undesirable, especially because the standard deviation of tongue
% 	movement is often curved.
% 
% 	The bounding box stipulation may be unnecessary if the path must always
% 	move forward (rightward). Extreme paths will be weeded out because they
% 	cannot reach the end point. Further testing is required.

% 
%	BEGIN MAIN FUNCTION
% 

% 	Read the video
	vr = VideoReader(filename);
	vidMatrix = vr2Matrix(vr);

% 	Create and show standard deviation image
	stdImage = reshape(std(vidMatrix,1),68,68);
	imagesc(stdImage)
	colormap gray

% 	Get start and end values
	disp('Click the brightest point of the lips (or lower lip).');
	[startX, startY] = ginput(1);
	disp('Click the brightest point of the tongue tip.');
	[endX, endY] = ginput(1);
	
% 	Close the standard deviation image
	close();
	
% 	Since each MRI pixel is represented by many pixels on the screen,
% 	ginput returns decimal values. Round them (should probably floor them
% 	instead)
	startX = round(startX);
	startY = round(startY);
	endX = round(endX);
	endY = round(endY);
	
% 	Holds the aggregate brightness values from a given point (row, col) to
% 	the endpoint.
	B = zeros(68,68);
	
% 	Holds the path from a given coordinate to the end point
	P = zeros(68,2,68*68);

% 	Holds the list of coordinates that have already been visited on a given
% 	path. Prevents cycling through the same points over and over again.
	visitedCoordinates = zeros(68, 68);
	
% 	Display the selected start and end points
	disp([int2str(startX) '\t' int2str(startY) '\t(start point)']);
	disp([int2str(endX) '\t' int2str(endY) '\t(end point)']);
	
%	Run the main function
	V(startX, startY, visitedCoordinates);
	
% 	Create image mask based on the brightest path (not sure if this gives
% 	the best path or just the last path. I mean, it definitely gives you
% 	the last path, but it's unclear if the last path is always the best)
	Pzero = find(P(1,1,:) == 0);
	bestPath = Pzero(1)-1;
	path = P(:,:,bestPath);
	path = path(any(path,2),:)
	mask = zeros(68, 68);
	for r = 1:size(path,1)
		mask(path(r,2), path(r,1)) = 1;
	end
	mask = mask * 500;
	
% 	Display the masked image
	maskedImage = stdImage + (20*(mask./max(max(mask))));
	imagesc(maskedImage);
	
% 	
% 	END MAIN FUNCTION
% 


% 
% 
%	LOCAL FUNCTIONS
% 
% 

%	Find the brightest path from the current point to the pre-specified end
%	point.
%	currentX -- the x coordinate of the current point
%	currentY -- the y coordinate of the current point
%	visitedCoordinates -- the points that have been traversed on this
%							particular path. Those points cannot be traversed again.
%	brightness -- the total brightness of the best path from the current
%					point to the end point
	function [brightness] = V(currentX, currentY, visitedCoordinates)
		
% 		Check if the best path from this point has already been calculated.
% 		If it has, just return the brightness of that path.
		if alreadyCalculated(currentX, currentY)
			brightness = B(currentX, currentY);
			return;
		end
		
% 		Add the current point to the list of visited points.
		visitedCoordinates(currentX, currentY) = 1.0;
		
		% If the current point is the end point, go no further
		if isequal([currentX, currentY], [endX, endY])
			B(currentX, currentY) = getBrightness(endX, endY);
			brightness = getBrightness(endX, endY);
			P(1,1,1) = endX;
			P(1,2,1) = endY;
			return;
		end
		
% 		Get the set of points that are reasonable continuations from this
% 		one
		adjacentPoints = getNextStates(currentX, currentY, visitedCoordinates);
		
% 		None of the next points are any good, which means this point is no
% 		good either
		s = size(adjacentPoints, 1);
		if s == 0
			brightness = -1;
			return;
		end
		
% 		Find the best paths from the next points
		potentialPaths = zeros(s,1);
		for i = 1:s
			potentialPaths(i) = V(adjacentPoints(i,1), adjacentPoints(i,2), visitedCoordinates);
		end
		
% 		Pick the path with largest total brightness. Points that weren't
% 		valid return brightness values of -1. If none of the next paths are
% 		good (i.e. all lead to dead ends), then this point is also no good.
		[maxBrightness, index] = max(potentialPaths);
		if maxBrightness == -1
			brightness = -1;
			return;
		end
		
% 		The best path from this point has been found.
		brightness = getBrightness(currentX, currentY) + maxBrightness;
		B(currentX, currentY) = brightness;
		assertPath(currentX, currentY, adjacentPoints, index);
		return;
	end

%	Add this path to the list of paths in P
%	currentX -- the x coordinate of the current point
%	currentY -- the y coordinate of the current point
%	adjacentPoints -- the set of reasonable continuations from the current
%						point
%	index -- identifies which coordinate in adjacentPoints provided the
%				brightest path
	function [] = assertPath(currentX, currentY, adjacentPoints, index)
		adjacentX = adjacentPoints(index,1);
		adjacentY = adjacentPoints(index,2);
		
		p = find(P(1,1,:) == adjacentX & P(1,2,:) == adjacentY);
		zIndex = p(1);
		pathSegment = P(:,:,zIndex);
		
		newPath = [currentX, currentY; pathSegment];
		trimmedPath = newPath(1:68,:);
		
		rowToReplace = find(P(1,1,:) == 0);
		rowToReplace = rowToReplace(1);
		P(:,:,rowToReplace) = trimmedPath;
	end

	% Returns the pixel coordinates of the next possible states.
%	currentX -- the x coordinate of the current point
%	currentY -- the y coordinate of the current point
%	visitedCoordinates -- the points that have been traversed on this
%							particular path. Those points cannot be traversed again.
	function [nextStates] = getNextStates(currentX, currentY, visitedCoordinates)
		nextStates = [];
		
% 		Check each point to make sure it's valid and hasn't been visited.

% %		[x, y+1]
% 		x = currentX;
% 		y = currentY + 1;
% 		if pointIsValid(x, y) && ~alreadyVisited(x, y, visitedCoordinates)
% 			nextStates = [nextStates; x, y];
% 		end
		
% % 	[x+1, y+1]
		x = currentX + 1;
		y = currentY + 1;
		if pointIsValid(x, y) && ~alreadyVisited(x, y, visitedCoordinates)
			nextStates = [nextStates; x, y];
		end
		
% % 	[x+1, y]
		x = currentX + 1;
		y = currentY;
		if pointIsValid(x, y) && ~alreadyVisited(x, y, visitedCoordinates)
			nextStates = [nextStates; x, y];
		end
		
% % 	[x+1, y-1]
		x = currentX + 1;
		y = currentY - 1;
		if pointIsValid(x, y) && ~alreadyVisited(x, y, visitedCoordinates)
			nextStates = [nextStates; x, y];
		end
		
% % 	[x, y-1]
% 		x = currentX;
% 		y = currentY - 1;
% 		if pointIsValid(x, y) && ~alreadyVisited(x, y, visitedCoordinates)
% 			nextStates = [nextStates; x, y];
% 		end
		
		return;
	end

	% Determines if the submitted coordinate is within the bounding box and
	% has not been traversed. Returns TRUE if the point is good, FALSE if
	% the point is bad.
% 	x -- x coordinate
%	y -- y coordinate
%	value -- TRUE or FALSE
	function [value] = pointIsValid(x, y)
		value = true;
		if x < min(startX,endX) || x > max(startX,endX) %|| y > max(startY,endY) || y < min(startY,endY)
			value = false;
		end
	end

%	Determines if the best path from the submitted coordinate has already
%	been found. Returns TRUE if the path has been found, FALSE if it has
%	not
% 	x -- x coordinate
%	y -- y coordinate
%	value -- TRUE or FALSE
	function [value] = alreadyCalculated(x, y)
		value = false;
		if B(x, y) > 0.0
			value = true;
		end
	end

%	Determines if the submitted coordinate has already been visited on this
%	path. Returns TRUE if the point has been visited, FALSE if it has not
% 	x -- x coordinate
%	y -- y coordinate
%	visitedCoordinates -- the points that have been traversed on this
%							particular path. Those points cannot be traversed again.
%	value -- TRUE or FALSE
	function [value] = alreadyVisited(x, y, visitedCoordinates)
		value = false;
		if visitedCoordinates(x, y) > 0.0
			value = true;
		end
	end

%	Retrieve the brightness of the submitted coordinate from the standard
%	deviation image. Images are oriented weirdly, so you access with (y, x)
%	rather than (x, y)
% 	x -- x coordinate
%	y -- y coordinate
%	brightness -- the floating point brightness at this coordinate
	function brightness = getBrightness(x, y)
		brightness = stdImage(y, x);
	end

end

