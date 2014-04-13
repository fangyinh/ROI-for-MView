function [] = loadIntoMViewRT( filename )
%loadIntoMViewRT load pre-constructed time series for video 'filename'.avi
%   Detailed explanation goes here

no_ext = isempty(strfind(filename, '.avi'));
if ~no_ext
% 	filename came with an extension. Get rid of it.
	[~, filename, ~] = fileparts(filename);
end

disp('Opening time series in MViewRT...');

load(strcat([filename '/ts_vel.mat']));
load(strcat([filename '/ts_tt.mat']));

data = prepareTimeSeries(ts_tt, ts_vel);
dataForMView = FormatData(data, filename);

mviewRT(dataForMView, filename)

end

