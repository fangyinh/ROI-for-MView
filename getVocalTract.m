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
	numFrames = vr.NumberOfFrames;
	framerate = vr.FrameRate;
	vidMatrix = vr2Matrix(vr);

% 	Create and show standard deviation image
	stdImage = reshape(std(vidMatrix,1),68,68);
	imagesc(stdImage)
	colormap gray

% 	Get start and end values
	disp('Click the brightest point of the lips (or lower lip).');
	[startX, startY] = ginput(1);
	disp('Click the at the back of the tongue body.');
	[midX, midY] = ginput(1);
	disp('Click the at the larynx.');
	[endX, endY] = ginput(1);
	
% 	Close the standard deviation image
	close();
	
% 	Since each MRI pixel is represented by many pixels on the screen,
% 	ginput returns decimal values. Round them.
	startX = round(startX);
	startY = round(startY);
	midX = round(midX);
	midY = round(midY);
	endX = round(endX);
	endY = round(endY);
	
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
	visitedCoordinates = zeros(68, 68);
	
% 	Display the selected start and end points
	disp([int2str(startX) '\t' int2str(startY) '\t(lips point)']);
	disp([int2str(midX) '\t' int2str(midY) '\t(tongue back point)']);
	disp([int2str(endX) '\t' int2str(endY) '\t(larynx point)']);
	

	V(startX, startY, visitedCoordinates);
	Vdown(midX, midY, visitedCoordinates);

	
% 	Create image mask based on the brightest path (not sure if this gives
% 	the best path or just the last path. I mean, it definitely gives you
% 	the last path, but it's unclear if the last path is always the best)
	Pzero = find(P(1,1,:) == 0);
	bestPath = Pzero(1)-1;
	path = P(:,:,bestPath);
	path = path(any(path,2),:);
	
	Pzerodown = find(Pdown(1,1,:) == 0);
	bestPathDown = Pzerodown(1)-1;
	pathdown = Pdown(:,:,bestPathDown);
	pathdown = pathdown(any(pathdown,2),:);
	
	x1 = path(end-4, 1);
	y1 = path(end-4, 2);
	x2 = pathdown(5,1);
	y2 = pathdown(5,2);
	for z = 1:(size(path)-5)
		visitedCoordinates(path(z,1),path(z,2)) = 1.0;
	end
	for z = 6:(size(pathdown))
		visitedCoordinates(pathdown(z,1),pathdown(z,2)) = 1.0;
	end
	Vmid(x1, y1, x1, y1, x2, y2, visitedCoordinates);
	
	Pzeromid = find(Pmid(1,1,:) == 0);
	bestPathMid = Pzeromid(1)-1;
	pathmid = Pmid(:,:,bestPathMid);
	pathmid = pathmid(any(pathmid,2),:);
	
	topPath = path(1:end-5,:);
	bottomPath = pathdown(5:end,:);
	
	wholepath = [topPath; pathmid; bottomPath];
	
% 	wholepath = [path; pathdown];
	
	mask = zeros(68, 68);
	for r = 1:size(wholepath,1)
		mask(wholepath(r,2), wholepath(r,1)) = 1;
	end
	mask = mask * 500;
	
% 	Display the masked image
% 	maskedStdImage = stdImage + (2*(mask./max(max(mask))));
	meanImage = reshape(mean(vidMatrix,1),68,68);
	maskedMeanImage = meanImage + (2*(mask./max(max(mask))));
% 	imagesc(maskedStdImage);
% 	
% 	close();
	
	imagesc(maskedMeanImage);
	
	LAB = extractArticulator(wholepath, numFrames, 'lips');
	TT = extractArticulator(wholepath, numFrames, 'tongue tip');
	TB = extractArticulator(wholepath, numFrames, 'tongue body');
	TR = extractArticulator(wholepath, numFrames, 'tongue root');
	VEL = extractVelum();

	LAB.framerate = framerate;
	LAB.vidMatrix = vidMatrix;
	LAB.meanImage = meanImage;
	
	TT.framerate = framerate;
	TT.vidMatrix = vidMatrix;
	TT.meanImage = meanImage;
	
	TB.framerate = framerate;
	TB.vidMatrix = vidMatrix;
	TB.meanImage = meanImage;
	
	TR.framerate = framerate;
	TR.vidMatrix = vidMatrix;
	TR.meanImage = meanImage;
	
	VEL.framerate = framerate;
	VEL.vidMatrix = vidMatrix;
	VEL.meanImage = meanImage;
	
	LAB.saveAs(filename);
	TT.saveAs(filename);
	TB.saveAs(filename);
	TR.saveAs(filename);
	VEL.saveAs(filename);
	
	
	
	
	
	
	
	
	
	
	
	
% % % 	Find the regions for each point
% 	radius = 3;
% 	numPoints = size(path, 1);
% 	fullMask = zeros(68, 68);
% 	rawTS = zeros(numFrames, 68, 68);
% 	filtTS = zeros(numFrames, 68, 68);
% 	for po = 1:numPoints
% 		rx = path(po, 1);
% 		ry = path(po, 2);
% 		[ts_cra_xy, mask_xy] = regionsmanual(vidMatrix,[ry rx],radius);
% 		rawTS(:,rx,ry) = ts_cra_xy;
% 		
% 		% NEW FILTER FUNCTION
% 		interp = 1; % basically, how many subintervals you want to be considered between each frame
% 		wwid = .9;
% 
% 		X	= 1:size(ts_cra_xy(:,1));
% 		Y	= ts_cra_xy;
% 		% D	= linspace(min(X),max(X),(interp*(max(X)-min(X))))';
% 		D	= linspace(min(X),max(X),(interp*max(X)))';
% 		[ts_filt_xy, ~] = lwregress( X',Y,D,wwid, 0 );
% 		filtTS(:,rx,ry) = ts_filt_xy;
% 		
% 		fullMask = fullMask + mask_xy;
% 	end
% 	
% 	radius = 3;
% 	numPointsDown = size(pathdown,1);
% 	for po = 1:numPointsDown
% 		rx = pathdown(po, 1);
% 		ry = pathdown(po, 2);
% 		[ts_cra_xy, mask_xy] = regionsmanual(vidMatrix,[ry rx],radius);
% 		rawTS(:,rx,ry) = ts_cra_xy;
% 		
% 		% NEW FILTER FUNCTION
% 		interp = 1; % basically, how many subintervals you want to be considered between each frame
% 		wwid = .9;
% 
% 		X	= 1:size(ts_cra_xy(:,1));
% 		Y	= ts_cra_xy;
% 		% D	= linspace(min(X),max(X),(interp*(max(X)-min(X))))';
% 		D	= linspace(min(X),max(X),(interp*max(X)))';
% 		[ts_filt_xy, ~] = lwregress( X',Y,D,wwid, 0 );
% 		filtTS(:,rx,ry) = ts_filt_xy;
% 		
% 		fullMask = fullMask + mask_xy;
% 	end
% 	
% 	
% 	assignin('base', 'rawTS', rawTS);
% 	assignin('base', 'filtTS', filtTS);
% 	
% % 	Display full mask
% 	fullMask = fullMask * 500;
% 	meanImage = reshape(mean(vidMatrix,1),68,68);
% 	fullyMaskedImage = meanImage + (20*fullMask./max(max(fullMask)));
% 	imagesc(fullyMaskedImage)
	
% 	
% 	END MAIN FUNCTION
% 




% 
% 
%	LOCAL FUNCTIONS
% 
% 

	function [instance] = extractArticulator(wholepath, numFrames, articulatorName)
		disp(['Click the point on the path that is closest to the front of the ' articulatorName '.']);
		[frontX, frontY] = ginput(1);
		frontX = round(frontX);
		frontY = round(frontY);
		tempPath = [frontX frontY; wholepath];
		D = squareform(pdist(tempPath));
		[~, iFront] = min(D(1,2:end));
		
		disp(['Click the point on the path that is closest to the back of the ' articulatorName '.']);
		[backX, backY] = ginput(1);
		backX = round(backX);
		backY = round(backY);
		tempPath = [backX backY; wholepath];
		D = squareform(pdist(tempPath));
		[~, iBack] = min(D(1,2:end));
		
		m = ceil((iBack + iFront) / 2);
		
		radius = 3;
		if isequal(articulatorName, 'tongue root')
			radius = 4;
		elseif isequal(articulatorName, 'lips')
			articulatorName = 'labial';
		end
		
		regionTS = zeros(numFrames, (iBack-iFront+1));
		artMask = zeros(68, 68);
		for k = iFront:iBack
			rx = wholepath(k, 1);
			ry = wholepath(k, 2);
			[ts_cra_xy, mask_xy] = regionsmanual(vidMatrix,[ry rx],radius);
			regionTS(:,(k-iFront+1)) = ts_cra_xy;
			artMask = artMask + mask_xy;
		end
		avgTS = mean(regionTS,2);
		
% 		Flip the time series so that constrictions happen at local minima
%		(this is how MViewRT works)
		avgTS = max(avgTS) - avgTS + min(avgTS);
		
		% NEW FILTER FUNCTION
		disp('Filtering time series...');
		interp = 1; % basically, how many subintervals you want to be considered between each frame
		wwid = .9;
		X	= 1:size(avgTS(:,1));
		Y	= avgTS;
		% D	= linspace(min(X),max(X),(interp*(max(X)-min(X))))';
		D	= linspace(min(X),max(X),(interp*max(X)))';
		[ts_filt, ~] = lwregress( X',Y,D,wwid, 0 );
		
		str = lower(articulatorName);
		idx = regexp([' ' str],'(?<=\s+)\S','start')-1;
		str(idx) = upper(str(idx));
		str = str(~isspace(str));
		className = strcat(str, 'TimeSeries');
		
		instance = eval(className);
		instance.radius = radius;
		instance.maskedImage = meanImage + (20*(artMask./max(max(artMask))));
		instance.mask = artMask;
		instance.x = wholepath(m, 1);
		instance.y = wholepath(m, 2);
		instance.ts_cra = avgTS;
		instance.ts_filt = ts_filt;
	end

	function [VEL] = extractVelum()
		regionSize = 1;
		tau = 0.6;
		pixelMinimum = 5;
		
		disp('Click the top edge of the velum.');
		[x, y] = ginput(1);
		x = round(x);
		y = round(y);
		
		minx = x-regionSize;
		maxx = x+regionSize;
		miny = y-regionSize;
		maxy = y+regionSize;
		
		dynamic_range = 0.000;
		
		for i = minx:maxx
			for j = miny:maxy

				% Time Series
				% cramanual takes the coordinates backwards--[y x] is correct, not [x y]
				[ts_cra_ij, mask_ij] = cramanual_short(vr,vidMatrix,tau,[j i]);

				pixelCount = numel(mask_ij( mask_ij(:)>0 ));
				if pixelCount >= pixelMinimum
					filt_range = range(ts_cra_ij);

					if filt_range > dynamic_range
						dynamic_range = filt_range;
						ts_cra = ts_cra_ij;
						finalmask = mask_ij;
						x = i;
						y = j;
					end
				end
			end
		end
		
		% NEW FILTER FUNCTION
		disp('Filtering time series...');
		interp = 1; % basically, how many subintervals you want to be considered between each frame
		wwid = .9;

		X	= 1:size(ts_cra(:,1));
		Y	= ts_cra;
		% D	= linspace(min(X),max(X),(interp*(max(X)-min(X))))';
		D	= linspace(min(X),max(X),(interp*max(X)))';
		[ts_filt, ~] = lwregress( X',Y,D,wwid, 0 );
		
		maskedImage = meanImage + (20*(finalmask./max(max(finalmask))));

		VEL = VelumTimeSeries;
		VEL.tau = tau;
		VEL.maskedImage = maskedImage;
		VEL.mask = finalmask;
		VEL.x = x;
		VEL.y = y;
		VEL.ts_cra = ts_cra;
		VEL.ts_filt = ts_filt;
	end



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
		if isequal([currentX, currentY], [midX, midY])
% 			B(currentX, currentY) = getBrightness(endX, endY);
% 			brightness = getBrightness(endX, endY);
			B(currentX, currentY) = stdImage(midY, midX);
			brightness = stdImage(midY, midX);
			P(1,1,1) = midX;
			P(1,2,1) = midY;
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
		if x <= midX && y <= (midX-x)+midY && y >= (midX-x)-midY && ~(visitedCoordinates(x, y) > 0.0)
			adjacentPoints = [adjacentPoints; x, y];
			s = s + 1;
% 			points(1,:) = [x, y];
		end
		
% % 	[x+1, y]
		x = currentX + 1;
		y = currentY;
		if x <= midX && y <= (midX-x)+midY && y >= (midX-x)-midY && ~(visitedCoordinates(x, y) > 0.0)
			adjacentPoints = [adjacentPoints; x, y];
			s = s + 1;
% 			points(2,:) = [x, y];
		end
		
% % 	[x+1, y-1]
		x = currentX + 1;
		y = currentY - 1;
		if x <= midX && y <= (midX-x)+midY && y >= (midX-x)-midY && ~(visitedCoordinates(x, y) > 0.0)
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
		if isequal([currentX, currentY], [endX, endY])
% 			B(currentX, currentY) = getBrightness(endX, endY);
% 			brightness = getBrightness(endX, endY);
			Bdown(currentX, currentY) = stdImage(endY, endX);
			brightness = stdImage(endY, endX);
			Pdown(1,1,1) = endX;
			Pdown(1,2,1) = endY;
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
		if y <= endY && x <= (endY-y)+endX && x >= (endY-y)-endX && ~(visitedCoordinates(x, y) > 0.0)
			adjacentPoints = [adjacentPoints; x, y];
			s = s + 1;
% 			points(1,:) = [x, y];
		end
		
% % 	[x, y+1]
		x = currentX;
		y = currentY + 1;
% 		if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
		if y <= endY && x <= (endY-y)+endX && x >= (endY-y)-endX && ~(visitedCoordinates(x, y) > 0.0)
			adjacentPoints = [adjacentPoints; x, y];
			s = s + 1;
% 			points(2,:) = [x, y];
		end
		
% % 	[x-1, y+1]
		x = currentX - 1;
		y = currentY + 1;
% 		if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
		if y <= endY && x <= (endY-y)+endX && x >= (endY-y)-endX && ~(visitedCoordinates(x, y) > 0.0)
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

	function [brightness] = Vmid(currentX, currentY, startX, startY, endX, endY, visitedCoordinates)
		
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
		if isequal([currentX, currentY], [endX, endY])
% 			B(currentX, currentY) = getBrightness(endX, endY);
% 			brightness = getBrightness(endX, endY);
			Bmid(currentX, currentY) = Bdown(endX, endY);
			brightness = Bdown(endX, endY);
			Pmid(1,1,1) = endX;
			Pmid(1,2,1) = endY;
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
% 		if y <= endY && x <= (endY-y)+endX && x >= (endY-y)-endX && ~(visitedCoordinates(x, y) > 0.0)
		if y <= max(endY, startY) && y >= min(endY, startY) && x <= max(endX, startX) && x >= min(endX, startX) && ~(visitedCoordinates(x, y) > 0.0)
			adjacentPoints = [adjacentPoints; x, y];
			s = s + 1;
% 			points(1,:) = [x, y];
		end
		
% % 	[x, y+1]
		x = currentX;
		y = currentY + 1;
% 		if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
		if y <= max(endY, startY) && y >= min(endY, startY) && x <= max(endX, startX) && x >= min(endX, startX) && ~(visitedCoordinates(x, y) > 0.0)
			adjacentPoints = [adjacentPoints; x, y];
			s = s + 1;
% 			points(2,:) = [x, y];
		end
		
% % 	[x+1, y]
		x = currentX + 1;
		y = currentY;
% 		if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
		if y <= max(endY, startY) && y >= min(endY, startY) && x <= max(endX, startX) && x >= min(endX, startX) && ~(visitedCoordinates(x, y) > 0.0)
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
			potentialPaths(i) = Vmid(adjacentPoints(i,1), adjacentPoints(i,2), startX, startY, endX, endY, visitedCoordinates);
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
		Bmid(currentX, currentY) = brightness;
% 		assertPath(currentX, currentY, adjacentPoints, index);


		% Do assertPath work without function call
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

