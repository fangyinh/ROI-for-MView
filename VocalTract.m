classdef VocalTract < handle
	%UNTITLED Summary of this class goes here
	%   Detailed explanation goes here
	
	properties
		LAB
		TT
		TB
		TR
		VEL
		filename
		nameForStorage
	end
	
	properties (Access = private)
		vidMatrix
		numFrames
		framerate
		midline		% an Nx2 matrix listing the points on the midline path
		mask		% a 68x68 matrix in which the mask points are > 0.0
	end
	
	methods
		function [obj] = VocalTract(filename, midline)
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
			obj.midline = midline;
		end
		
		function [vidMatrix] = getVidMatrix(obj)
			vidMatrix = obj.vidMatrix;
		end
		
		function [numFrames] = getNumFrames(obj)
			numFrames = obj.numFrames;
		end
		
		function [framerate] = getFramerate(obj)
			framerate = obj.framerate;
		end
		
		function [midline] = getMidline(obj)
			if isempty(obj.midline)
				disp('ERROR: You cannot access the vocal tract midline before calling the getVocalTract() method on your VocalTract object.');
				midline = [];
				return;
			end
			midline = obj.midline;
		end
		
		function [mask] = getMask(obj)
			if isempty(obj.midline)
				disp('ERROR: You cannot access the vocal tract mask before calling the getVocalTract() method on your VocalTract object.');
				mask = [];
				return;
			end
			mask = obj.mask;
		end
		
		function [meanImage] = getMeanImage(obj)
			meanImage = reshape(mean(obj.vidMatrix,1),68,68);
		end
		
		function [] = showMeanImage(obj)
			meanImage = obj.getMeanImage();
			imagesc(meanImage);
			colormap gray;
		end
		
		function [stdImage] = getStdImage(obj)
			stdImage = reshape(std(obj.vidMatrix,1),68,68);
		end
		
		function [] = showStdImage(obj)
			stdImage = obj.getStdImage();
			imagesc(stdImage);
			colormap gray;
		end
		
		function [] = showMidline(obj, imgType)
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
			[~, dir, ~] = fileparts(obj.filename);
			if ~exist(dir, 'dir')
				mkdir(dir);
			end
			save(strcat(dir,'/',obj.nameForStorage),'obj');
		end
		
		function [startPoint, midPoint, endPoint] = init(obj)
			figure('name','Select anchor points');
			obj.showStdImage();
			
			[startX, startY] = obj.getPointFromClick('Click at the front of the lower lip.');
			[midX, midY] = obj.getPointFromClick('Click at the back of the tongue body.');
			[endX, endY] = obj.getPointFromClick('Click at the larynx.');
			
			close('Select anchor points');
			
			startPoint = [startX, startY];
			midPoint = [midX, midY];
			endPoint = [endX, endY];
			
% 			dp = DynamicProgammer(obj.getStdImage());
			dp = DynamicProgrammer();
			dp.setImage(obj.getStdImage());
			obj.midline = dp.findPath([startPoint; midPoint; endPoint]);
			
			obj.setArticulator({'LAB', 'TT', 'TB', 'TR', 'VEL'});
		end
		
		function [] = setArticulator(obj, articulatorNames)
			if isempty(obj.midline)
				disp('ERROR: Before you can set any articulators, you must first call the method getVocalTract on your VocalTract object.');
				return;
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
			if nargin > 1
				disp(message);
			end
			
			[raw_x, raw_y] = ginput(1);
			x = round(raw_x);
			y = round(raw_y);
		end
		
		function [] = extractArticulator(obj, articulator)
			figure('name',['Select points for the ',articulator.displayName]);
			obj.showMidline('mean');
			
			if ~articulator.isEmpty()
				disp(['WARNING: You are about to overwrite the data collected for the ' articulator.displayName '. If you close the picture window or quit this script now, your data will not be overwritten.']);
			end
			
			if isa(articulator, 'Velum')
				[x, y] = obj.getPointFromClick(['Click at the top of the ' articulator.displayName '.']);
				articulator.run([x y], obj.vidMatrix, obj.numFrames);
			else
				[frontX, frontY] = obj.getPointFromClick(['Click the point on the path that is closest to the front of the ' articulator.displayName '.']);
				tempPath = [frontX frontY; obj.midline];
				D = squareform(pdist(tempPath));
				[~, iFront] = min(D(1,2:end));

				[backX, backY] = obj.getPointFromClick(['Click the point on the path that is closest to the back of the ' articulator.displayName '.']);
				tempPath = [backX backY; obj.midline];
				D = squareform(pdist(tempPath));
				[~, iBack] = min(D(1,2:end));

				articulator.run(obj.midline(iFront:iBack,:), obj.vidMatrix, obj.numFrames);
			end
			close(['Select points for the ',articulator.displayName]);
		end
		
		function [mask] = shapeMidline(obj)
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
	end
	
	methods (Static)
		function [obj, filename] = load(filename)
			no_ext = isempty(strfind(filename, '.avi'));
			if ~no_ext
			% 	filename came with an extension. Get rid of it.
				[~, filename, ~] = fileparts(filename);
			end
			file = load(strcat([filename '/' filename '_vt.mat']));
			obj = file.obj;
		end
		
		function [] = loadIntoMViewRT(filename)
			[obj, filename] = VocalTract.load(filename);
			
			data.fps = obj.framerate;
			
			frames = 0:(obj.numFrames-1); % 1 gets added in FormatData.m, so subtract it here (assuming the frames are 1-based instead of 0-based, I suppose)
			times = frames ./ obj.framerate;

			articulators = {'LAB', 'TT', 'TB', 'TR', 'VEL'};
			
			for k = 1:numel(articulators)
				str = articulators{k};
				articulator = obj.(str);
				
				if ~articulator.isEmpty()
					data.gest(k).name = articulator.name;
					data.gest(k).location = [articulator.x, articulator.y];

					data.gest(k).frames = frames;
					data.gest(k).times = times;

					data.gest(k).Ismoothed = articulator.ts_filt;
					data.gest(k).stimes = times;
				end
			end
			
			dataForMView = FormatData(data, filename); % This function should be with the other MViewRT functions

			mviewRT(dataForMView, 'LPROC', 'lp_findgest');
		end
	end
	
end

