function [] = trackTongueTip(filename, radius)
%trackTongueTip 

if nargin < 2
	radius = 4;
end

regionSize = 1;

% Video
vr = VideoReader(filename);
framerate = vr.FrameRate;
vidMatrix = vr2Matrix(vr);

% Get Analysis Location
g = figure;
meanImage = reshape(mean(vidMatrix,1),68,68);
imagesc(meanImage)
colormap gray
[x, y] = ginput(1);

% Create meanImage directory
[~, name, ~] = fileparts(filename);
dir = name;
if ~exist(dir, 'dir')
	mkdir(dir);
end
% [status, ~, messageid] = mkdir(dir);
% if status==0
% 	if strcmp(messageid,'MATLAB:MKDIR:DirectoryExists') == 0
% 		disp('Crash!');
% 		return
% 	else
% 		disp(strcat(['Overwriting directory ' dir]));
% 	end
% end
print(g,'-dpng',strcat(dir,'/meanGrayImage'));
close();

x = round(x);
y = round(y);
minx = x-regionSize;
maxx = x+regionSize;
miny = y-regionSize;
maxy = y+regionSize;

dynamic_range = 0.000;
bestTimeSeries = TongueTipTimeSeries;
bestTimeSeries.framerate = framerate;
bestTimeSeries.vidMatrix = vidMatrix;
bestTimeSeries.meanImage = meanImage;
bestTimeSeries.radius = radius;

for i = minx:maxx
	for j = miny:maxy

		[ts_cra, mask] = regionsmanual(vidMatrix,[y x], radius);
			
		% 			% Filter TS
% 			cutoff = 2; %Hz
% 			[b, a] = butter(9,cutoff/(framerate/2),'low');
% 			ts_filt = filtfilt(b,a,ts_cra);
			
% 			NEW FILTER FUNCTION
interp = 5;
wwid = .9;

% create finer-spaced timeline over which to interpolate intensity function
% ff = a 1x2 matrix containing the start and end frame values in the
% interval being measured
% nfr = the number of frames being measured
% ff_ = a vector with interp*nfr values between the lower end of ff and the
% higher end of ff (essentially, it subdivides the frames by a factor of
% interp)
% I = the y-values of the data points, aka ts_cra

% nfr	= ff(end)-ff(1);
% ff_	= linspace( ff(1),ff(end), interp*nfr );

[numFrames, ~] = size(ts_cra);
nfr = numFrames-1;
ff_ = linspace(1, numFrames, interp*nfr);
I = ts_cra;

% smooth intensity plot using locally weighted linear regression
[ts_filt, ~]	= lwregress( ff',I',ff_', wwid, 0 );

		filt_range = range(ts_filt);

		if (filt_range > dynamic_range)
			maskedImage = meanImage + (20*(mask./max(max(mask))));
			bestTimeSeries.mask = mask;
			bestTimeSeries.maskedImage = maskedImage;
			bestTimeSeries.x = i;
			bestTimeSeries.y = j;
			bestTimeSeries.ts_cra = ts_cra;
			bestTimeSeries.ts_filt = ts_filt;
			dynamic_range = filt_range;
		end
	end
end

% The best time series has been selected
% Save masked image picture
h = figure;
imagesc(bestTimeSeries.maskedImage)
print(h,'-dpng',strcat(dir,'/maskedImageTT'));
close();

ts_tt = bestTimeSeries;
% Save the best time series object into a .mat file
save(strcat(dir,'/ts_tt'),'ts_tt');

end

