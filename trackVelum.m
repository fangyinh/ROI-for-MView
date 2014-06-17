function [ts_vel]=trackVelum(filename,tau)

if nargin < 2
	tau = 0.6;
end

regionSize = 1;
pixelMinimum = 5;

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
print(g,'-dpng',strcat(dir,'/meanGrayImage'));
close();

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
				mask = mask_ij;
				x = i;
				y = j;
			end
		end
	end
end

% Right now, constrictions are at local maxima. MViewRT doesn't like this,
% so reverse it.
% Current status: LOCAL MINIMUM CORRESPONDS TO VELUM LOWERING GESTURE
% Uncomment the next few lines for status: LOCAL MINIMUM CORRESPONDS TO
% VELUM CLOSING GESTURE

% ts_max = max(ts_cra);
% ts_min = min(ts_cra);
% ts_cra = ts_max - ts_cra + ts_min;

% NEW FILTER FUNCTION
disp('Filtering time series...');
interp = 1; % basically, how many subintervals you want to be considered between each frame
wwid = .9;

X	= 1:size(ts_cra(:,1));
Y	= ts_cra;
% D	= linspace(min(X),max(X),(interp*(max(X)-min(X))))';
D	= linspace(min(X),max(X),(interp*max(X)))';
[ts_filt, ~] = lwregress( X',Y,D,wwid, 0 );

maskedImage = meanImage + (20*(mask./max(max(mask))));

ts_vel = VelumTimeSeries;
ts_vel.framerate = framerate;
ts_vel.vidMatrix = vidMatrix;
ts_vel.meanImage = meanImage;
ts_vel.tau = tau;
ts_vel.maskedImage = maskedImage;
ts_vel.mask = mask;
ts_vel.x = x;
ts_vel.y = y;
ts_vel.ts_cra = ts_cra;
ts_vel.ts_filt = ts_filt;

% The best time series has been selected
% Save masked image picture
h = figure;
imagesc(ts_vel.maskedImage)
print(h,'-dpng',strcat(dir,'/maskedImageVEL'));
close();

% Save the best time series object into a .mat file
save(strcat(dir,'/ts_vel'),'ts_vel');

return