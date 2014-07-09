classdef DynamicProgrammer < handle
	%UNTITLED2 Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (Access = private)
		B
		P
		image
	end
	
	methods
		function [obj] = DynamicProgrammer(image)
			obj.reset;
			if nargin > 0
				obj.image = image;
			end
		end
		
		function [] = setImage(obj, image)
			obj.image = image;
		end
		
		function [wholePath] = findPath(obj, points)
% 			visitedCoordinates = zeros(68*68,2);
			visitedCoordinates = [];
			
			startPoint = points(2,:);
			endPoint = points(3,:);
			V(obj, startPoint, endPoint, 'down');
			
			path2 = obj.filterPath();
			
			obj.reset();
			
			startPoint = points(1,:);
			endPoint = points(2,:);
			V(obj, startPoint, endPoint, 'right');
			
			path1 = obj.filterPath();
			
			wholePath = [path1; path2];
			
% % 			s1 = size(path1,1);
% % 			s2 = size(path2,1);
% % 			x1 = path1(end-4, 1);
% % 			y1 = path1(end-4, 2);
% % 			x2 = path2(5,1);
% % 			y2 = path2(5,2);
% % 			visitedCoordinates(1:s1-5, :) = path1(1:end-5,:);
% % 			visitedCoordinates(s1-4:(s2+s1-4), :) = path2(6:end,:);
% 			
% 			s1 = size(path1,1);
% 			s2 = size(path2,1);
% 			m1 = floor(s1/5);
% 			m2 = floor(s2/5);
% 			x1 = path1(end-m1, 1);
% 			y1 = path1(end-m1, 2);
% 			x2 = path2(m2,1);
% 			y2 = path2(m2,2);
% 			visitedCoordinates = [path1(1:end-m1,:); path2(m2+1:end,:)];
% % 			visitedCoordinates(1:s1-m1, :) = path1(1:end-m1,:);
% % 			visitedCoordinates(s1-m1+1:(s2+s1-m1+1), :) = path2(m2+1:end,:);
% 			
% 			
% % 			for z = 1:(size(path1)-5)
% % 				visitedCoordinates(path1(z,1),path1(z,2)) = 1.0;
% % 			end
% % 			for z = 6:(size(path2))
% % 				visitedCoordinates(path2(z,1),path2(z,2)) = 1.0;
% % 			end
% 			obj.V([x1, y1], [x2, y2], visitedCoordinates, 'downright');
% 
% 			path3 = obj.filterPath();
% 
% 			topPath = path1(1:end-m1,:);
% 			bottomPath = path2(m2+1:end,:);
% 
% 			wholePath = [topPath; path3; bottomPath];
		end
	end
	
	methods (Access = private)
		function [] = reset(obj)
			obj.B = zeros(68,68);
			obj.P = zeros(68,2,68*68);
		end
		
		function [path] = filterPath(obj)
			Pzero = find(obj.P(1,1,:) == 0);
			bestPath = Pzero(1)-1;
			unfilteredPath = obj.P(:,:,bestPath);
			path = unfilteredPath(any(unfilteredPath,2),:);
		end
		
		function [] = V(obj, startPoint, endPoint, direction)
			startX = startPoint(1,1);
			startY = startPoint(1,2);
			endX = endPoint(1,1);
			endY = endPoint(1,2);
			
			switch direction
				case 'right'
					t = endX - startX;
				case 'down'
					t = endY - startY;
				case 'downright'
				otherwise
			end
			obj.B(endX, endY) = obj.image(endY, endX);
			obj.P(1,1,1) = endX;
			obj.P(1,2,1) = endY;
			states = endPoint;

			for j = 0:t
				newStates = [];
				for i = 1:size(states, 1)
					currentPoint = states(i,:);
					currentX = currentPoint(1,1);
					currentY = currentPoint(1,2);
					
			% 		Get the set of points that are reasonable continuations
			% 		from this one
					switch direction
						case 'right'
							adjacentPoints = [currentX+1, currentY-1; currentX+1, currentY; currentX+1, currentY+1];
							adjacentBrightnesses = [obj.B(currentX+1, currentY-1); obj.B(currentX+1, currentY); obj.B(currentX+1, currentY+1)];
							
					% % 	[x-1, y+1] downleft
							x = currentX - 1;
							y = currentY + 1;
							if y <= startY+(t-j) && y >= startY-(t-j)
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
						case 'down'
							adjacentPoints = [currentX+1, currentY+1; currentX, currentY+1; currentX-1, currentY+1];
							adjacentBrightnesses = [obj.B(currentX+1, currentY+1); obj.B(currentX, currentY+1); obj.B(currentX-1, currentY+1)];
							
					% % 	[x+1, y-1] upright
							x = currentX + 1;
							y = currentY - 1;
							if x <= startX+(t-j) && x >= startX-(t-j)
								newStates = [newStates; x, y];
							end

					% % 	[x, y-1] up
							x = currentX;
							y = currentY - 1;
							if x <= startX+(t-j) && x >= startX-(t-j)
								newStates = [newStates; x, y];
							end

					% % 	[x-1, y-1] upleft
							x = currentX - 1;
							y = currentY - 1;
							if x <= startX+(t-j) && x >= startX-(t-j)
								newStates = [newStates; x, y];
							end
						case 'downright'
							
						otherwise
					end
					
					if isequal(currentPoint, endPoint) % Values for the initial case have already been supplied, so skip this iteration and move on to the next stage
						continue;
					end
					
					[previous_brightness, index] = max(adjacentBrightnesses);

			% 		The best path from this point has been found.
					brightness = obj.image(currentY, currentX) + previous_brightness;
					obj.B(currentX, currentY) = brightness;

					% Add this point to the potential path
					adjacentX = adjacentPoints(index,1);
					adjacentY = adjacentPoints(index,2);

					p = find(obj.P(1,1,:) == adjacentX & obj.P(1,2,:) == adjacentY);
					zIndex = p(1);
					pathSegment = obj.P(:,:,zIndex);

					newPath = [currentPoint; pathSegment];
					trimmedPath = newPath(1:68,:);

					rowToReplace = find(obj.P(1,1,:) == 0);
					rowToReplace = rowToReplace(1);
					obj.P(:,:,rowToReplace) = trimmedPath;
			
				end
				states = unique(newStates, 'rows');
			end
		end
		
% 		function [brightness] = V(obj, currentPoint, endPoint, visitedCoordinates, direction)
% 			currentX = currentPoint(1,1);
% 			currentY = currentPoint(1,2);
% 			endX = endPoint(1,1);
% 			endY = endPoint(1,2);
% 			
% % 			Check if the best path from this point has already been calculated.
% % 			If it has, just return the brightness of that path.
% 			if obj.B(currentX, currentY) > 0.0
% 				brightness = obj.B(currentX, currentY);
% 				return;
% 			end
% 
% % 			Add the current point to the list of visited points.
% % 			visitedCoordinates(currentX, currentY) = 1.0;
% 			visitedCoordinates = [visitedCoordinates; currentPoint];
% % 			z = find(visitedCoordinates(:,1) == 0);
% % 			visitedCoordinates(z(1),:) = currentPoint;
% 
% % 			If the current point is the end point, go no further
% 			if isequal(currentPoint, endPoint)
% 				obj.B(currentX, currentY) = obj.image(endY, endX);
% 				brightness = obj.image(endY, endX);
% 				obj.P(1,1,1) = endX;
% 				obj.P(1,2,1) = endY;
% 				return;
% 			end
% 
% % 			Get the set of points that are reasonable continuations from this
% % 			one
% 			adjacentPoints = [];
% 			prev = [];
% 			if size(visitedCoordinates, 1) >=2
% 				prev = visitedCoordinates(end-1,:);
% 			end
% 			
% 			switch direction
% 				case 'right'
% % 					[x+1,y-1], up and right
% 					x = currentX + 1;
% 					y = currentY - 1;
% % 					if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
% 					if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~ismember([x, y], visitedCoordinates, 'rows')
% 						adjacentPoints = [adjacentPoints; x, y];
% 					end
% 
% % 					[x+1, y], right
% 					x = currentX + 1;
% 					y = currentY;
% % 					if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
% 					if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~ismember([x, y], visitedCoordinates, 'rows')
% 						adjacentPoints = [adjacentPoints; x, y];
% 					end
% 
% % 					[x+1, y+1], down and right
% 					x = currentX + 1;
% 					y = currentY + 1;
% % 					if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
% 					if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~ismember([x, y], visitedCoordinates, 'rows')
% 						adjacentPoints = [adjacentPoints; x, y];
% 					end
% 				case 'down'
% % 					[x+1, y+1], down and right
% 					x = currentX + 1;
% 					y = currentY + 1;
% % 					if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
% % 					if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~ismember([x, y], visitedCoordinates, 'rows')
% 					if y <= endY && x <= (endY-y)+endX && x >= (endY-y)-endX && ~ismember([x, y], visitedCoordinates, 'rows')
% 						adjacentPoints = [adjacentPoints; x, y];
% 					end
% 
% % 					[x, y+1], down
% 					x = currentX;
% 					y = currentY + 1;
% % 					if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
% % 					if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~ismember([x, y], visitedCoordinates, 'rows')
% 					if y <= endY && x <= (endY-y)+endX && x >= (endY-y)-endX && ~ismember([x, y], visitedCoordinates, 'rows')
% 						adjacentPoints = [adjacentPoints; x, y];
% 					end
% 
% % 					[x-1, y+1], down and left
% 					x = currentX - 1;
% 					y = currentY + 1;
% % 					if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
% % 					if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~ismember([x, y], visitedCoordinates, 'rows')
% 					if y <= endY && x <= (endY-y)+endX && x >= (endY-y)-endX && ~ismember([x, y], visitedCoordinates, 'rows')
% 						adjacentPoints = [adjacentPoints; x, y];
% 					end
% 				case 'downright'
% % 					[x+1, y], right
% 					x = currentX + 1;
% 					y = currentY;
% % 					if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
% % 					if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~ismember([x, y], visitedCoordinates, 'rows')
% 					if y <= endY && x <= endX && ~ismember([x, y], visitedCoordinates, 'rows')
% % 						if ~isempty(prev) && (prev(1,1) ~= currentX || prev(1,2) ~= currentY-1)
% 							adjacentPoints = [adjacentPoints; x, y];
% % 						end
% 					end
% 
% % 					[x+1, y+1], down and right
% 					x = currentX + 1;
% 					y = currentY + 1;
% % 					if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
% % 					if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~ismember([x, y], visitedCoordinates, 'rows')
% 					if y <= endY && x <= endX && ~ismember([x, y], visitedCoordinates, 'rows')
% 						adjacentPoints = [adjacentPoints; x, y];
% 					end
% 
% % 					[x, y+1], down
% 					x = currentX;
% 					y = currentY + 1;
% % 					if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
% % 					if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~ismember([x, y], visitedCoordinates, 'rows')
% 					if y <= endY && x <= endX && ~ismember([x, y], visitedCoordinates, 'rows')
% % 						if ~isempty(prev) && (prev(1,1) ~= currentX-1 || prev(1,2) ~= currentY)
% 							adjacentPoints = [adjacentPoints; x, y];
% % 						end
% 					end
% 				otherwise
% 					
% 			end
% 			
% % %			[x+1,y-1], up and right
% % 			if ismember('upright', directions)
% % 				x = currentX + 1;
% % 				y = currentY - 1;
% % % 				if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
% % 				if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~ismember([x, y], visitedCoordinates, 'rows')
% % 					adjacentPoints = [adjacentPoints; x, y];
% % 				end
% % 			end
% % 
% % %			[x+1, y], right
% % 			if ismember('right', directions)
% % 				x = currentX + 1;
% % 				y = currentY;
% % % 				if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
% % 				if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~ismember([x, y], visitedCoordinates, 'rows')
% % 					if ~isempty(prev) && prev(1,1) ~= currentX && prev(1,2) ~= currentY-1
% % 						adjacentPoints = [adjacentPoints; x, y];
% % 					end
% % 				end
% % 			end
% % 			
% % %			[x+1, y+1], down and right
% % 			if ismember('downright', directions)
% % 				x = currentX + 1;
% % 				y = currentY + 1;
% % % 				if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
% % 				if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~ismember([x, y], visitedCoordinates, 'rows')
% % 					adjacentPoints = [adjacentPoints; x, y];
% % 				end
% % 			end
% % 
% % %			[x, y+1], down
% % 			if ismember('down', directions)
% % 				x = currentX;
% % 				y = currentY + 1;
% % % 				if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
% % 				if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~ismember([x, y], visitedCoordinates, 'rows')
% % 					if ~isempty(prev) && prev(1,1) ~= currentX-1 && prev(1,2) ~= currentY
% % 						adjacentPoints = [adjacentPoints; x, y];
% % 					end
% % 				end
% % 			end
% % 
% % %			[x-1, y+1], down and left
% % 			if ismember('downleft', directions)
% % 				x = currentX - 1;
% % 				y = currentY + 1;
% % % 				if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~(visitedCoordinates(x, y) > 0.0)
% % 				if x <= endX && y <= (endX-x)+endY && y >= (endX-x)-endY && ~ismember([x, y], visitedCoordinates, 'rows')
% % 					adjacentPoints = [adjacentPoints; x, y];
% % 				end
% % 			end
% 			
% 			
% % 			None of the next points are any good, which means this point is no
% % 			good either
% 			s = size(adjacentPoints,1);
% 			if s == 0
% 				brightness = -1;
% 				return;
% 			end
% 
% % 			Find the best paths from the next points
% 			potentialPaths = zeros(s,1);
% 			for i = 1:s
% 				potentialPaths(i) = obj.V(adjacentPoints(i,:), endPoint, visitedCoordinates, direction);
% 			end
% 
% % 			Pick the path with largest total brightness. Points that weren't
% % 			valid return brightness values of -1. If none of the next paths are
% % 			good (i.e. all lead to dead ends), then this point is also no good.
% 			[maxBrightness, index] = max(potentialPaths);
% 			if maxBrightness == -1
% 				brightness = -1;
% 				return;
% 			end
% 
% % 			The best path from this point has been found.
% 			brightness = obj.image(currentY, currentX) + maxBrightness;
% 			obj.B(currentX, currentY) = brightness;
% 
% 
% 			adjacentX = adjacentPoints(index,1);
% 			adjacentY = adjacentPoints(index,2);
% 			p = find(obj.P(1,1,:) == adjacentX & obj.P(1,2,:) == adjacentY);
% % 			p = find(obj.P(1,:,:) == adjacentPoints(index,:));
% 			pathSegment = obj.P(:,:,p(1));
% 
% 			newPath = [currentPoint; pathSegment];
% 			trimmedPath = newPath(1:68,:);
% 
% 			rowToReplace = find(obj.P(1,1,:) == 0);
% 			rowToReplace = rowToReplace(1);
% 			obj.P(:,:,rowToReplace) = trimmedPath;
% 		end
	end
	
end