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
	disp('Click the at the back of the tongue body.');
	[endX, endY] = ginput(1);
	disp('Click the at the larynx.');
	[larX, larY] = ginput(1);
	
% 	Close the standard deviation image
	close();
	
% 	Since each MRI pixel is represented by many pixels on the screen,
% 	ginput returns decimal values. Round them (should probably floor them
% 	instead)
	startX = round(startX);
	startY = round(startY);
	endX = round(endX);
	endY = round(endY);
	larX = round(larX);
	larY = round(larY);
	
% 	Holds the aggregate brightness values from a given point (row, col) to
% 	the endpoint.
	B = zeros(68,68);
	Bdown = zeros(68,68);
	
% 	Holds the path from a given coordinate to the end point
	P = zeros(68,2,68*68);
	Pdown = zeros(68,2,68*68);

% 	Holds the list of coordinates that have already been visited on a given
% 	path. Prevents cycling through the same points over and over again.
	visitedCoordinates = zeros(68, 68);
	
% 	Display the selected start and end points
	disp([int2str(startX) '\t' int2str(startY) '\t(lips point)']);
	disp([int2str(endX) '\t' int2str(endY) '\t(tongue back point)']);
	disp([int2str(larX) '\t' int2str(larY) '\t(larynx point)']);
	
% 	totalAPtime = 0.0;
% 	totalAPcount = 0;
% 	totalPIVtime = 0.0;
% 	pivcount = 0;
% 	totalNStime = 0.0;
% 	subNStime = 0.0;
% 	nscount = 0;
% 	totalACtime = 0.0;
% 	account = 0;
% 	totalAVtime = 0.0;
% 	avcount = 0;
% 	totalGBtime = 0.0;
% 	gbcount = 0;
	
%	Run the main function
% 	tMain = tic;
	V(startX, startY, visitedCoordinates);
	Vdown(endX, endY, visitedCoordinates);
% 	mainTime = toc(tMain);
% 	disp(['entire V function: ',num2str(mainTime)]);
% 	disp(['total assertPath time: ',num2str(totalAPtime)]);
% 	disp(['average assertPath time: ',num2str(totalAPtime / totalAPcount)]);
% 	disp(['total pointIsValid time: ',num2str(totalPIVtime)]);
% 	disp(['average pointIsValid time: ',num2str(totalPIVtime / pivcount)]);
% 	disp(['total nextStates time: ',num2str(totalNStime)]);
% 	disp(['average nextStates time: ',num2str(totalNStime / nscount)]);
% 	disp(['total sub-nextStates time: ',num2str(subNStime)]);
% 	disp(['average sub-nextStates time: ',num2str(subNStime / nscount)]);
% 	disp(['total alreadyCalculated time: ',num2str(totalACtime)]);
% 	disp(['average alreadyCalculated time: ',num2str(totalACtime / account)]);
% 	disp(['total alreadyVisited time: ',num2str(totalAVtime)]);
% 	disp(['average alreadyVisited time: ',num2str(totalAVtime / avcount)]);
% 	disp(['total getBrightness time: ',num2str(totalGBtime)]);
% 	disp(['average getBrightness time: ',num2str(totalGBtime / gbcount)]);
	
% 	Create image mask based on the brightest path (not sure if this gives
% 	the best path or just the last path. I mean, it definitely gives you
% 	the last path, but it's unclear if the last path is always the best)
	Pzero = find(P(1,1,:) == 0);
	bestPath = Pzero(1)-1;
	path = P(:,:,bestPath);
	path = path(any(path,2),:)
	
	Pzerodown = find(Pdown(1,1,:) == 0);
	bestPathDown = Pzerodown(1)-1;
	pathdown = Pdown(:,:,bestPathDown);
	pathdown = pathdown(any(pathdown,2),:)
	
	wholepath = [path; pathdown];
	
	mask = zeros(68, 68);
	for r = 1:size(wholepath,1)
		mask(wholepath(r,2), wholepath(r,1)) = 1;
	end
	mask = mask * 500;
	
% 	Display the masked image
	maskedImage = stdImage + (2*(mask./max(max(mask))));
	imagesc(maskedImage);
	
% 	close();
	
% % 	Find the regions for each point
	radius = 3;
	numPoints = size(path, 1);
	fullMask = zeros(68, 68);
	rawTS = zeros(673, 68, 68);
	filtTS = zeros(673, 68, 68);
	for po = 1:numPoints
		rx = path(po, 1);
		ry = path(po, 2);
		[ts_cra_xy, mask_xy] = regionsmanual(vidMatrix,[ry rx],radius);
		rawTS(:,rx,ry) = ts_cra_xy;
		
		% NEW FILTER FUNCTION
		interp = 1; % basically, how many subintervals you want to be considered between each frame
		wwid = .9;

		X	= 1:size(ts_cra_xy(:,1));
		Y	= ts_cra_xy;
		% D	= linspace(min(X),max(X),(interp*(max(X)-min(X))))';
		D	= linspace(min(X),max(X),(interp*max(X)))';
		[ts_filt_xy, ~] = lwregress( X',Y,D,wwid, 0 );
		filtTS(:,rx,ry) = ts_filt_xy;
		
		fullMask = fullMask + mask_xy;
	end
	
	radius = 3;
	numPointsDown = size(pathdown,1);
	for po = 1:numPointsDown
		rx = pathdown(po, 1);
		ry = pathdown(po, 2);
		[ts_cra_xy, mask_xy] = regionsmanual(vidMatrix,[ry rx],radius);
		rawTS(:,rx,ry) = ts_cra_xy;
		
		% NEW FILTER FUNCTION
		interp = 1; % basically, how many subintervals you want to be considered between each frame
		wwid = .9;

		X	= 1:size(ts_cra_xy(:,1));
		Y	= ts_cra_xy;
		% D	= linspace(min(X),max(X),(interp*(max(X)-min(X))))';
		D	= linspace(min(X),max(X),(interp*max(X)))';
		[ts_filt_xy, ~] = lwregress( X',Y,D,wwid, 0 );
		filtTS(:,rx,ry) = ts_filt_xy;
		
		fullMask = fullMask + mask_xy;
	end
	
	
	assignin('base', 'rawTS', rawTS);
	assignin('base', 'filtTS', filtTS);
	
% 	Display full mask
	fullMask = fullMask * 500;
	meanImage = reshape(mean(vidMatrix,1),68,68);
	fullyMaskedImage = meanImage + (20*fullMask./max(max(fullMask)));
	imagesc(fullyMaskedImage)
	
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
% 		if alreadyCalculated(currentX, currentY)
		if B(currentX, currentY) > 0.0
			brightness = B(currentX, currentY);
			return;
		end
		
% 		Add the current point to the list of visited points.
		visitedCoordinates(currentX, currentY) = 1.0;
		
		% If the current point is the end point, go no further
		if isequal([currentX, currentY], [endX, endY])
% 			B(currentX, currentY) = getBrightness(endX, endY);
% 			brightness = getBrightness(endX, endY);
			B(currentX, currentY) = stdImage(endY, endX);
			brightness = stdImage(endY, endX);
			P(1,1,1) = endX;
			P(1,2,1) = endY;
			return;
		end
		
% 		Get the set of points that are reasonable continuations from this
% 		one
% 		adjacentPoints = getNextStates(currentX, currentY, visitedCoordinates);
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%		
		adjacentPoints = [];
		s = 0;
		
% % 	[x+1, y+1]
		x = currentX + 1;
		y = currentY + 1;
		if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
			adjacentPoints = [adjacentPoints; x, y];
			s = s + 1;
% 			points(1,:) = [x, y];
		end
		
% % 	[x+1, y]
		x = currentX + 1;
		y = currentY;
		if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
			adjacentPoints = [adjacentPoints; x, y];
			s = s + 1;
% 			points(2,:) = [x, y];
		end
		
% % 	[x+1, y-1]
		x = currentX + 1;
		y = currentY - 1;
		if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
			adjacentPoints = [adjacentPoints; x, y];
			s = s + 1;
% 			points(3,:) = [x, y];
		end
		
%%%%%%%%%%%%%%%%%%%%%%%
		
		
		
		
		
		
		
% 		None of the next points are any good, which means this point is no
% 		good either
% 		s = size(adjacentPoints, 1);
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
% 		brightness = getBrightness(currentX, currentY) + maxBrightness;
		brightness = stdImage(currentY, currentX) + maxBrightness;
		B(currentX, currentY) = brightness;
% 		assertPath(currentX, currentY, adjacentPoints, index);


		% Do assertPath work without function call
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

		return;
	end






	function [brightness] = Vdown(currentX, currentY, visitedCoordinates)
		
% 		Check if the best path from this point has already been calculated.
% 		If it has, just return the brightness of that path.
% 		if alreadyCalculated(currentX, currentY)
		if Bdown(currentX, currentY) > 0.0
			brightness = Bdown(currentX, currentY);
			return;
		end
		
% 		Add the current point to the list of visited points.
		visitedCoordinates(currentX, currentY) = 1.0;
		
		% If the current point is the end point, go no further
		if isequal([currentX, currentY], [larX, larY])
% 			B(currentX, currentY) = getBrightness(endX, endY);
% 			brightness = getBrightness(endX, endY);
			Bdown(currentX, currentY) = stdImage(larY, larX);
			brightness = stdImage(larY, larX);
			Pdown(1,1,1) = larX;
			Pdown(1,2,1) = larY;
			return;
		end
		
% 		Get the set of points that are reasonable continuations from this
% 		one
% 		adjacentPoints = getNextStates(currentX, currentY, visitedCoordinates);
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%		
		adjacentPoints = [];
		s = 0;
		
% % 	[x+1, y+1]
		x = currentX + 1;
		y = currentY + 1;
% 		if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
		if y <= larY && x <= (larY-y)+larX && x >= (larY-y)-larX && ~(visitedCoordinates(x, y) > 0.0)
			adjacentPoints = [adjacentPoints; x, y];
			s = s + 1;
% 			points(1,:) = [x, y];
		end
		
% % 	[x, y+1]
		x = currentX;
		y = currentY + 1;
% 		if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
		if y <= larY && x <= (larY-y)+larX && x >= (larY-y)-larX && ~(visitedCoordinates(x, y) > 0.0)
			adjacentPoints = [adjacentPoints; x, y];
			s = s + 1;
% 			points(2,:) = [x, y];
		end
		
% % 	[x-1, y+1]
		x = currentX - 1;
		y = currentY + 1;
% 		if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
		if y <= larY && x <= (larY-y)+larX && x >= (larY-y)-larX && ~(visitedCoordinates(x, y) > 0.0)
			adjacentPoints = [adjacentPoints; x, y];
			s = s + 1;
% 			points(3,:) = [x, y];
		end
		
%%%%%%%%%%%%%%%%%%%%%%%
		
		
		
		
		
		
		
% 		None of the next points are any good, which means this point is no
% 		good either
% 		s = size(adjacentPoints, 1);
		if s == 0
			brightness = -1;
			return;
		end
		
% 		Find the best paths from the next points
		potentialPaths = zeros(s,1);
		for i = 1:s
			potentialPaths(i) = Vdown(adjacentPoints(i,1), adjacentPoints(i,2), visitedCoordinates);
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
% 		brightness = getBrightness(currentX, currentY) + maxBrightness;
		brightness = stdImage(currentY, currentX) + maxBrightness;
		Bdown(currentX, currentY) = brightness;
% 		assertPath(currentX, currentY, adjacentPoints, index);


		% Do assertPath work without function call
		adjacentX = adjacentPoints(index,1);
		adjacentY = adjacentPoints(index,2);
		
		p = find(Pdown(1,1,:) == adjacentX & Pdown(1,2,:) == adjacentY);
		zIndex = p(1);
		pathSegment = Pdown(:,:,zIndex);
		
		newPath = [currentX, currentY; pathSegment];
		trimmedPath = newPath(1:68,:);
		
		rowToReplace = find(Pdown(1,1,:) == 0);
		rowToReplace = rowToReplace(1);
		Pdown(:,:,rowToReplace) = trimmedPath;

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
		tAssertPath = tic;
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
		aptime = toc(tAssertPath);
		totalAPtime = totalAPtime + aptime;
		totalAPcount = totalAPcount + 1;
	end

%%%
%%% OLD NEXTSTATES
%%%
% 	% Returns the pixel coordinates of the next possible states.
% %	currentX -- the x coordinate of the current point
% %	currentY -- the y coordinate of the current point
% %	visitedCoordinates -- the points that have been traversed on this
% %							particular path. Those points cannot be traversed again.
% 	function [nextStates] = getNextStates(currentX, currentY, visitedCoordinates)
% 		tnextstates = tic;
% % 		nextStates = [];
% 		points = zeros(3,2);
% 		
% % 		Check each point to make sure it's valid and hasn't been visited.
% 
% % %		[x, y+1]
% % 		x = currentX;
% % 		y = currentY + 1;
% % 		if pointIsValid(x, y) && ~alreadyVisited(x, y, visitedCoordinates)
% % 			nextStates = [nextStates; x, y];
% % 		end
% 		
% % % 	[x+1, y+1]
% 		x = currentX + 1;
% 		y = currentY + 1;
% 		if pointIsValid(x, y) && ~alreadyVisited(x, y, visitedCoordinates)
% % 			nextStates = [nextStates; x, y];
% 			points(1,:) = [x, y];
% 		end
% 		
% % % 	[x+1, y]
% 		x = currentX + 1;
% 		y = currentY;
% 		if pointIsValid(x, y) && ~alreadyVisited(x, y, visitedCoordinates)
% % 			nextStates = [nextStates; x, y];
% 			points(2,:) = [x, y];
% 		end
% 		
% % % 	[x+1, y-1]
% 		x = currentX + 1;
% 		y = currentY - 1;
% 		if pointIsValid(x, y) && ~alreadyVisited(x, y, visitedCoordinates)
% % 			nextStates = [nextStates; x, y];
% 			points(3,:) = [x, y];
% 		end
% 		
% % % 	[x, y-1]
% % 		x = currentX;
% % 		y = currentY - 1;
% % 		if pointIsValid(x, y) && ~alreadyVisited(x, y, visitedCoordinates)
% % 			nextStates = [nextStates; x, y];
% % 		end
% 		
% 		tt = tic;
% 		numNonZero = nnz(points);
% 		if numNonZero > 0
% 			nextStates = zeros((numNonZero/2), 2);
% 			start = 1;
% 			for p = 1:3
% 				if ~isequal(points(p,:), [0,0])
% 					nextStates(start,:) = points(p,:);
% 					start = start + 1;
% 				end
% 			end
% 		else
% 			nextStates = [];
% 		end
% 		sub = toc(tt);
% 		subNStime = subNStime + sub;
% 
% 		t = toc(tnextstates);
% 		totalNStime = totalNStime + t;
% 		nscount = nscount + 1;
% 		
% 		return;
% 	end

%%%
%%% NEW NEXTSTATES
%%%

	% Returns the pixel coordinates of the next possible states.
%	currentX -- the x coordinate of the current point
%	currentY -- the y coordinate of the current point
%	visitedCoordinates -- the points that have been traversed on this
%							particular path. Those points cannot be traversed again.
	function [nextStates] = getNextStates(currentX, currentY, visitedCoordinates)
		tnextstates = tic;
		nextStates = [];
% 		points = zeros(3,2);
		
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
		if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
			nextStates = [nextStates; x, y];
% 			points(1,:) = [x, y];
		end
		
% % 	[x+1, y]
		x = currentX + 1;
		y = currentY;
		if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
			nextStates = [nextStates; x, y];
% 			points(2,:) = [x, y];
		end
		
% % 	[x+1, y-1]
		x = currentX + 1;
		y = currentY - 1;
		if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
			nextStates = [nextStates; x, y];
% 			points(3,:) = [x, y];
		end
		
% % 	[x, y-1]
% 		x = currentX;
% 		y = currentY - 1;
% 		if pointIsValid(x, y) && ~alreadyVisited(x, y, visitedCoordinates)
% 			nextStates = [nextStates; x, y];
% 		end
		
% 		tt = tic;
% 		numNonZero = nnz(points);
% 		if numNonZero > 0
% 			nextStates = zeros((numNonZero/2), 2);
% 			start = 1;
% 			for p = 1:3
% 				if ~isequal(points(p,:), [0,0])
% 					nextStates(start,:) = points(p,:);
% 					start = start + 1;
% 				end
% 			end
% 		else
% 			nextStates = [];
% 		end
% 		sub = toc(tt);
% 		subNStime = subNStime + sub;

		t = toc(tnextstates);
		totalNStime = totalNStime + t;
		nscount = nscount + 1;
		
		return;
	end

%%%
%%% END NEW NEXTSTATES
%%%

	% Determines if the submitted coordinate is within the bounding box and
	% has not been traversed. Returns TRUE if the point is good, FALSE if
	% the point is bad.
% 	x -- x coordinate
%	y -- y coordinate
%	value -- TRUE or FALSE
	function [value] = pointIsValid(x, y)
		tpiv = tic;
		value = true;
% 		if x < min(startX,endX) || x > max(startX,endX) || y > (max(startY,endY) + (abs(endX - startX)/2)) || y < (min(startY,endY) - (abs(endX - startX)/2))
% 		if x < min(startX,endX) || x > max(startX,endX) || y > (abs(endX-x)+endY) || y < (abs(endX-x)-endY)
		if x > endX || y > (endX-x)+endY || y < (endX-x)-endY
			value = false;
		end
		ftime = toc(tpiv);
		totalPIVtime = totalPIVtime + ftime;
		pivcount = pivcount + 1;
	end

%	Determines if the best path from the submitted coordinate has already
%	been found. Returns TRUE if the path has been found, FALSE if it has
%	not
% 	x -- x coordinate
%	y -- y coordinate
%	value -- TRUE or FALSE
	function [value] = alreadyCalculated(x, y)
		talreadycalc = tic;
		value = false;
		if B(x, y) > 0.0
			value = true;
		end
		t = toc(talreadycalc);
		totalACtime = totalACtime + t;
		account = account + 1;
	end

%	Determines if the submitted coordinate has already been visited on this
%	path. Returns TRUE if the point has been visited, FALSE if it has not
% 	x -- x coordinate
%	y -- y coordinate
%	visitedCoordinates -- the points that have been traversed on this
%							particular path. Those points cannot be traversed again.
%	value -- TRUE or FALSE
	function [value] = alreadyVisited(x, y, visitedCoordinates)
		tav = tic;
		value = false;
		if visitedCoordinates(x, y) > 0.0
			value = true;
		end
		t = toc(tav);
		totalAVtime = totalAVtime + t;
		avcount = avcount + 1;
	end

%	Retrieve the brightness of the submitted coordinate from the standard
%	deviation image. Images are oriented weirdly, so you access with (y, x)
%	rather than (x, y)
% 	x -- x coordinate
%	y -- y coordinate
%	brightness -- the floating point brightness at this coordinate
	function brightness = getBrightness(x, y)
		tgb = tic;
		brightness = stdImage(y, x);
		t = toc(tgb);
		totalGBtime = totalGBtime + t;
		gbcount = gbcount + 1;
	end

end

