function [] = loadArticulatorsIntoMViewRT( filename )
%loadIntoMViewRT load pre-constructed time series for video 'filename'.avi
%   Detailed explanation goes here

no_ext = isempty(strfind(filename, '.avi'));
if ~no_ext
% 	filename came with an extension. Get rid of it.
	[~, filename, ~] = fileparts(filename);
end

disp('Opening time series in MViewRT...');

ts = load(strcat([filename '/ts_vel.mat']));
ts_vel = ts.ts_vel;
ts = load(strcat([filename '/ts_tt.mat']));
ts_tt = ts.instance;
ts = load(strcat([filename '/ts_dor.mat']));
ts_dor = ts.instance;
ts = load(strcat([filename '/ts_root.mat']));
ts_root = ts.instance;
ts = load(strcat([filename '/ts_lab.mat']));
ts_lab = ts.instance;

data = prepareTimeSeries(ts_lab, ts_tt, ts_dor, ts_root, ts_vel);
dataForMView = FormatData(data, filename); % This function should be with the other MViewRT functions

mviewRT(dataForMView, 'LPROC', 'lp_findgest')

end

