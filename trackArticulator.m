%
% To save:
% time series (ts_cra) (and the filtered one, if you want; filtering
%	requires the frame rate)
% mask image (R)
% mean image (MM)
% tau
% coordinates

function []=trackArticulator(filename,tau,coordinate)

if nargin < 3
	coordinate = false;
	if nargin < 2
		tau = 0.6;
	else
		if tau < 0.0 || tau > 1.0
			disp('The second argument must be between 0.0 and 1.0.');
		end
	end
end

% Video
vr = VideoReader(filename);
framerate = vr.FrameRate;
vidMatrix = vr2Matrix(vr);

% Create mean image
meanImage = reshape(mean(vidMatrix,1),68,68);
imagesc(meanImage)
colormap gray

% Check submitted coordinate
if coordinate ~= false
	if(isequal(size(coordinate),[1,2]))
		x = coordinate(1);
		y = coordinate(2);
	else
		disp('Third argument must be a single [x, y] coordinate.');
		return;
	end
else	
	% Get Analysis Location
	[x, y] = ginput(1);
	x = round(x);
	y = round(y);
	disp([x, y]);
end

% Time Series
% cramanual takes the coordinates backwards--[y x] is correct, not [x y]
[ts_cra, mask] = cramanual_short(vr,vidMatrix,tau,[y x]);
% imshow(mask)

% Filter TS
cutoff = 2; %Hz
[b, a] = butter(9,cutoff/(framerate/2),'low');
ts_filt = filtfilt(b,a,ts_cra);

% Save stuff
[~, name, ~] = fileparts(filename);
[status, ~, messageid] = mkdir(name);

if status==0
	if strcmp(messageid,'MATLAB:MKDIR:DirectoryExists') == 0
		disp('Crash!');
		return
	else
		disp(strcat('Overwriting directory ',name));
	end
end

cd(name);
print -dpng meanImagePic
close();

figure
maskedImage = meanImage + (20*(mask./max(max(mask))));
imagesc(maskedImage)

print -dpng maskedImagePic
cd ..

save(strcat(name,'/vars'),'framerate','vidMatrix','meanImage','maskedImage','mask','tau','ts_cra','ts_filt','x','y');





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