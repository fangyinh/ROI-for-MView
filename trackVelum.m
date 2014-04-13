function []=trackVelum(filename,tau)

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
bestTimeSeries = VelumTimeSeries;
bestTimeSeries.framerate = framerate;
bestTimeSeries.vidMatrix = vidMatrix;
bestTimeSeries.meanImage = meanImage;
bestTimeSeries.tau = tau;

for i = minx:maxx
	for j = miny:maxy
		
		% Time Series
		% cramanual takes the coordinates backwards--[y x] is correct, not [x y]
		[ts_cra, mask] = cramanual_short(vr,vidMatrix,tau,[j i]);
		
% 		NEW APPROACH
%		Because it takes so long to do the locally weighted linear
%		regression for a whole movie, do range-checking on the raw time
%		series rather than the filtered time series. This way, only time
%		series with large raw ranges will have to be filtered.
% 
%		Actually, if you're doing that, you can just hold off on filtering
%		until the end of the point-checking, then filter just the best one
		
		pixelCount = numel(mask( mask(:)>0 ));
		if pixelCount >= pixelMinimum
			
% 			% Filter TS
% 			cutoff = 2; %Hz
% 			[b, a] = butter(9,cutoff/(framerate/2),'low');
% 			ts_filt = filtfilt(b,a,ts_cra);
			
% 			NEW FILTER FUNCTION
			interp = 1; % basically, how many subintervals you want to be considered between each frame
			wwid = .9;

			X	= 1:size(ts_cra(:,1));
			Y	= ts_cra;
			D	= linspace(min(X),max(X),(interp*(max(X)-min(X))))';
			[ts_filt ~] = lwregress( X',Y,D,wwid, 0 );
			

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

			% Save stuff
% 			dir = strcat(name,'_',stri,'-',strj);
% 			[status, ~, messageid] = mkdir(dir);
% 
% 			if status==0
% % 				This never happens (but it did happen once because there
% % 				were non-string integers in the folder name)
% 				if strcmp(messageid,'MATLAB:MKDIR:DirectoryExists') == 0
% 					disp('Crash!');
% 					return
% 				else
% % 					This never happens.
% 					disp(strcat(['Overwriting directory ' dir]));
% 				end
% 			end
		end
	end
end

% The best time series has been selected
% Save masked image picture
h = figure;
imagesc(bestTimeSeries.maskedImage)
print(h,'-dpng',strcat(dir,'/maskedImageVEL'));
close();

ts_vel = bestTimeSeries;
% Save the best time series object into a .mat file
save(strcat(dir,'/ts_vel'),'ts_vel');






% % Viz TS
% figure
% plot(ts_filt,'b','linewidth',2);
% hold on
% 
% % Quantize Waveform - Kmeans
% [idx,C] = kmeans(ts_filt,3);
% [v, i] = sort(C,'descend');
% 
% % Viz TS Quantized
% plot(C(idx),'r');
% 
% % THRESHOLD CALCULATIONS
% % Moments of calibration
% % openning: 280, 288, 302, 587, 703 (first open frame)
% % closure: 283, 293, 589, 706 (first closed frame)
% %thresh_man = mean(ts_cra([280 288 302 587 703 283 293 589 706])); % corresp. 04_01_26
% thresh_man = 1.0793;
% thresh_k = mean(v(1:2));
% thresh_l = mean(v(2:3));
% 
% % Viz Thresholds
% %plot(thresh_man.*ones(length(ts_filt),1),'r');
% plot(thresh_k.*ones(length(ts_filt),1),'k--','linewidth',1.5);
% plot(thresh_l.*ones(length(ts_filt),1),'k--','linewidth',1.5);
% 
% % velocity!
% ts_diff = diff(ts_filt);
% 
% % Threshold percentage
% 100*(abs(thresh_man-thresh_k)./range(ts_filt)) 
% 
% % Viz adjustments
% scrsz = get(gcf,'Position');
% set(gcf,'PaperPositionMode','auto')
% set(gcf,'Position',[scrsz(1:2) scrsz(3)/0.5 scrsz(4)/2.0]);
% axis([0 length(ts_filt) 0.2 2.0])
% set(gca,'ytick',[]);
% 
% print -dpng VelumTS_f
% 
% % Hist
% hist(ts_filt,linspace(min(ts_filt),max(ts_filt),13))
% print -dpng VelumHist_f

return

%eof