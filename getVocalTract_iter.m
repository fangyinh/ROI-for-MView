function [ ] = getVocalTract_iter( filename )
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


% 
%	BEGIN MAIN FUNCTION
% 
	
% 	Initialize the vocal tract
	vt = VocalTract(filename);
	[startPoint, midPoint, endPoint] = vt.init();
	stdImage = vt.getStdImage();
	
% 	Holds the aggregate brightness values from a given point (row, col) to
% 	the endpoint.
	B = zeros(68,68);
	Bdown = zeros(68,68);
	Bmid = zeros(68,68);
	
% 	Holds the path from a given coordinate to the end point
	P = zeros(68,2,68*68);
	Pdown = zeros(68,2,68*68);
	Pmid = zeros(68,2,68*68);

% 	Holds the list of coordinates that have already been visited on a given
% 	path. Prevents cycling through the same points over and over again.
% 	visitedCoordinates = [];
	V(startPoint, midPoint);
	
% 	visitedCoordinates = zeros(68, 68);
% 	Vdown(midPoint, endPoint, visitedCoordinates);

	
% 	Extract the right and downward paths
	Pzero = find(P(1,1,:) == 0);
	bestPath = Pzero(1)-1;
	path = P(:,:,bestPath);
	path = path(any(path,2),:);
	
% 	Pzerodown = find(Pdown(1,1,:) == 0);
% 	bestPathDown = Pzerodown(1)-1;
% 	pathdown = Pdown(:,:,bestPathDown);
% 	pathdown = pathdown(any(pathdown,2),:);
% 	
% % 	Smooth the path around the point where dynamic programming switches
% % 	from rightward to downward (near [midX, midY])
% 	x1 = path(end-4, 1);
% 	y1 = path(end-4, 2);
% 	x2 = pathdown(5,1);
% 	y2 = pathdown(5,2);
% 	for z = 1:(size(path)-5)
% 		visitedCoordinates(path(z,1),path(z,2)) = 1.0;
% 	end
% 	for z = 6:(size(pathdown))
% 		visitedCoordinates(pathdown(z,1),pathdown(z,2)) = 1.0;
% 	end
% 	Vmid([x1, y1], [], [x1, y1], [x2, y2], visitedCoordinates);
% 	
% % 	Extract the corrected middle part of the path
% 	Pzeromid = find(Pmid(1,1,:) == 0);
% 	bestPathMid = Pzeromid(1)-1;
% 	pathmid = Pmid(:,:,bestPathMid);
% 	pathmid = pathmid(any(pathmid,2),:);
	
% 	mask = zeros(68, 68);
% 	for r = 1:size(pathmid,1)
% 		mask(pathmid(r,2), pathmid(r,1)) = 1;
% 	end
% 	mask = mask * 500;
% 	imagesc(mask);
% 	return;
	
% % 	Create the final path
% 	topPath = path(1:end-5,:);
% 	bottomPath = pathdown(5:end,:);
% 	
% 	wholePath = [topPath; pathmid; bottomPath];
	
	wholePath = path;
	
	vt.setMidline(wholePath);
	vt.showMidline('std');
% 	vt.setArticulator({'LAB', 'TT', 'TB', 'TR', 'VEL'});
% 	vt.save();
	
% 	
% 	END MAIN FUNCTION
% 




% 
% 
%	LOCAL FUNCTIONS
% 
% 

% Step 1:	Send a T-800 Terminator unit into the function's timeline, back
%			to the time of x_0		--DONE
% Step 2:	Move the recursive call and surrounding work into a helper
%			function				--DONE
% Step 3:	Partition the helper function into its three fundamental parts
%									--DONE(?)
% Step 4:	Secretly prepare to receive communications from the T-800
%			Terminator unit			--DONE
% Step 5:	Modify the helper's return statement to also pass through its
%			non-secret arguments	--DONE
% Step 6:	Apply, to the non-secret arguments in the helper's return
%			statement, the opposite of the transformations applied to the
%			recursive call			--DONE
% Step 7:	Determine the initial conditions at the start of the timeline
% Step 8:	In the main function, iterate the step helper t times, starting
%			from the initial conditions. Then return x_t (endX-startX)
% Step 9:	Remove the base cases from the original function
% Step 10:	Remove the secret feature from the step function
% Step 11:	Inline the step function
% Step 12:	Apply finishing touches

	function [previous_visitedCoordinates, brightness] = step(currentPoint, endPoint, visitedCoordinates, previous_brightness)
		
		currentX = currentPoint(1,1);
		currentY = currentPoint(1,2);
		endX = endPoint(1,1);
		endY = endPoint(1,2);
		
		if previous_brightness == -1
			brightness = -1;
			return;
		end
		
% 		The best path from this point has been found.
		brightness = stdImage(currentY, currentX) + previous_brightness;
		B(currentX, currentY) = brightness;

		% Add this point to the discovered path
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
		
		
% 		Get the set of points that are reasonable continuations from this
% 		one		
		previous_visitedCoordinates = [];

% % 	[x-1, y+1] downleft
		x = currentX - 1;
		y = currentY + 1;
		if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY % fix this after making step() inline; don't overshoot the left bound, don't go higher/lower than necessary
			previous_visitedCoordinates = [previous_visitedCoordinates; x, y];
		end

% % 	[x-1, y] left
		x = currentX - 1;
		y = currentY;
		if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY % fix this after making step() inline
			previous_visitedCoordinates = [previous_visitedCoordinates; x, y];
		end

% % 	[x-1, y-1] upleft
		x = currentX - 1;
		y = currentY - 1;
		if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY % fix this after making step() inline
			previous_visitedCoordinates = [previous_visitedCoordinates; x, y];
		end
	end

	function [] = V(startPoint, endPoint)
		startX = startPoint(1,1);
		startY = startPoint(1,2);
		endX = endPoint(1,1);
		endY = endPoint(1,2);
		
%		Seed the end value at j = 0; have to do it because there are no
%		previous points to pull brightness from
		j = 0;
		t = endX - startX;
		B(endX, endY) = stdImage(endY, endX);
		P(1,1,1) = endX;
		P(1,2,1) = endY;
		states = [];
% % 	[x-1, y+1] downleft
		x = endX - 1;
		y = endY + 1;
		if y <= startY+(t-j) && y >= startY-(t-j) %fix these
			states = [states; x, y];
		end
% % 	[x-1, y] left
		x = endX - 1;
		y = endY;
		if y <= startY+(t-j) && y >= startY-(t-j)
			states = [states; x, y];
		end
% % 	[x-1, y-1] upleft
		x = endX - 1;
		y = endY - 1;
		if y <= startY+(t-j) && y >= startY-(t-j)
			states = [states; x, y];
		end

		for j = 1:t
			newStates = [];
			for i = 1:size(states, 1)
				currentPoint = states(i,:);
				currentX = currentPoint(1,1);
				currentY = currentPoint(1,2);
				
%				Get the best previous_brightness possible
				adjacentPoints = [currentX+1, currentY-1; currentX+1, currentY; currentX+1, currentY+1];
				adjacentBrightnesses = [B(currentX+1, currentY-1); B(currentX+1, currentY); B(currentX+1, currentY+1)];
				[previous_brightness, index] = max(adjacentBrightnesses);

		% 		The best path from this point has been found.
				brightness = stdImage(currentY, currentX) + previous_brightness;
				B(currentX, currentY) = brightness;

				% Add this point to the potential path
				adjacentX = adjacentPoints(index,1);
				adjacentY = adjacentPoints(index,2);

				p = find(P(1,1,:) == adjacentX & P(1,2,:) == adjacentY);
				zIndex = p(1);
				pathSegment = P(:,:,zIndex);

				newPath = [currentPoint; pathSegment];
				trimmedPath = newPath(1:68,:);

				rowToReplace = find(P(1,1,:) == 0);
				rowToReplace = rowToReplace(1);
				P(:,:,rowToReplace) = trimmedPath;

		% 		Get the set of points that are reasonable continuations
		% 		from this one

		% % 	[x-1, y+1] downleft
				x = currentX - 1;
				y = currentY + 1;
				if y <= startY+(t-j) && y >= startY-(t-j) %fix these
					newStates = [newStates; x, y];
				end

		% % 	[x-1, y] left
				x = currentX - 1;
				y = currentY;
				if y <= startY+(t-j) && y >= startY-(t-j)
					newStates = [newStates; x, y];
				end

		% % 	[x-1, y-1] upleft
				x = currentX - 1;
				y = currentY - 1;
				if y <= startY+(t-j) && y >= startY-(t-j)
					newStates = [newStates; x, y];
				end
			end
			states = unique(newStates, 'rows');
		end
	end

	function [brightness] = Vdown(currentPoint, endPoint, visitedCoordinates)
		currentX = currentPoint(1,1);
		currentY = currentPoint(1,2);
		endX = endPoint(1,1);
		endY = endPoint(1,2);
		
% 		Check if the best path from this point has already been calculated.
% 		If it has, just return the brightness of that path.
		if Bdown(currentX, currentY) > 0.0
			brightness = Bdown(currentX, currentY);
			return;
		end
		
% 		Add the current point to the list of visited points.
		visitedCoordinates(currentX, currentY) = 1.0;
		
		% If the current point is the end point, go no further
		if isequal([currentX, currentY], [endX, endY])
			Bdown(currentX, currentY) = stdImage(endY, endX);
			brightness = stdImage(endY, endX);
			Pdown(1,1,1) = endX;
			Pdown(1,2,1) = endY;
			return;
		end
		
% 		Get the set of points that are reasonable continuations from this
% 		one
		adjacentPoints = [];
		s = 0;
		
% % 	[x+1, y+1] downright
		x = currentX + 1;
		y = currentY + 1;
		if y <= endY && x <= (endY-y)+endX && x >= (endY-y)-endX && ~(visitedCoordinates(x, y) > 0.0)
			adjacentPoints = [adjacentPoints; x, y];
			s = s + 1;
		end
		
% % 	[x, y+1] down
		x = currentX;
		y = currentY + 1;
		if y <= endY && x <= (endY-y)+endX && x >= (endY-y)-endX && ~(visitedCoordinates(x, y) > 0.0)
			adjacentPoints = [adjacentPoints; x, y];
			s = s + 1;
		end
		
% % 	[x-1, y+1] downleft
		x = currentX - 1;
		y = currentY + 1;
		if y <= endY && x <= (endY-y)+endX && x >= (endY-y)-endX && ~(visitedCoordinates(x, y) > 0.0)
			adjacentPoints = [adjacentPoints; x, y];
			s = s + 1;
		end
		
% 		None of the next points are any good, which means this point is no
% 		good either
		if s == 0
			brightness = -1;
			return;
		end
		
% 		Find the best paths from the next points
		potentialPaths = zeros(s,1);
		for i = 1:s
			potentialPaths(i) = Vdown(adjacentPoints(i,:), endPoint, visitedCoordinates);
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
		brightness = stdImage(currentY, currentX) + maxBrightness;
		Bdown(currentX, currentY) = brightness;

		% Add this point to the discovered path
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

	function [brightness] = Vmid(currentPoint, prevPoint, startPoint, endPoint, visitedCoordinates)
		currentX = currentPoint(1,1);
		currentY = currentPoint(1,2);
		start_X = startPoint(1,1);
		start_Y = startPoint(1,2);
		end_X = endPoint(1,1);
		end_Y = endPoint(1,2);
% 		Check if the best path from this point has already been calculated.
% 		If it has, just return the brightness of that path.
% 		if alreadyCalculated(currentX, currentY)
		if Bmid(currentX, currentY) > 0.0
			brightness = Bmid(currentX, currentY);
			return;
		end
		
% 		Add the current point to the list of visited points.
		visitedCoordinates(currentX, currentY) = 1.0;
		
		% If the current point is the end point, go no further
		if isequal([currentX, currentY], [end_X, end_Y])
% 			B(currentX, currentY) = getBrightness(endX, endY);
% 			brightness = getBrightness(endX, endY);
			Bmid(currentX, currentY) = Bdown(end_X, end_Y);
			brightness = Bdown(end_X, end_Y);
			Pmid(1,1,1) = end_X;
			Pmid(1,2,1) = end_Y;
			return;
		end
		
% 		Get the set of points that are reasonable continuations from this
% 		one
		adjacentPoints = [];
		s = 0;
		
% % 	[x+1, y+1] diagonal
		x = currentX + 1;
		y = currentY + 1;
		if y <= max(end_Y, start_Y) && y >= min(end_Y, start_Y) && x <= max(end_X, start_X) && x >= min(end_X, start_X) && ~(visitedCoordinates(x, y) > 0.0)
			adjacentPoints = [adjacentPoints; x, y];
			s = s + 1;
		end
		
% % 	[x, y+1] down
		x = currentX;
		y = currentY + 1;
		if y <= max(end_Y, start_Y) && y >= min(end_Y, start_Y) && x <= max(end_X, start_X) && x >= min(end_X, start_X) && ~(visitedCoordinates(x, y) > 0.0)
% 			if ~isempty(prevPoint) && (prevPoint(1,1) ~= currentX-1 || prevPoint(1,2) ~= currentY)
				adjacentPoints = [adjacentPoints; x, y];
				s = s + 1;
% 			end
		end
		
% % 	[x+1, y] right
		x = currentX + 1;
		y = currentY;
		if y <= max(end_Y, start_Y) && y >= min(end_Y, start_Y) && x <= max(end_X, start_X) && x >= min(end_X, start_X) && ~(visitedCoordinates(x, y) > 0.0)
% 			if ~isempty(prevPoint) && (prevPoint(1,1) ~= currentX || prevPoint(1,2) ~= currentY-1)
				adjacentPoints = [adjacentPoints; x, y];
				s = s + 1;
% 			end
		end
		
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
			potentialPaths(i) = Vmid(adjacentPoints(i,:), currentPoint, startPoint, endPoint, visitedCoordinates);
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
		brightness = stdImage(currentY, currentX) + maxBrightness;
		Bmid(currentX, currentY) = brightness;

		% Add this point to the discovered path
		adjacentX = adjacentPoints(index,1);
		adjacentY = adjacentPoints(index,2);
		
		p = find(Pmid(1,1,:) == adjacentX & Pmid(1,2,:) == adjacentY);
		zIndex = p(1);
		pathSegment = Pmid(:,:,zIndex);
		
		newPath = [currentX, currentY; pathSegment];
		trimmedPath = newPath(1:68,:);
		
		rowToReplace = find(Pmid(1,1,:) == 0);
		rowToReplace = rowToReplace(1);
		Pmid(:,:,rowToReplace) = trimmedPath;

		return;
	end

end

