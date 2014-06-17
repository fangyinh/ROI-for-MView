function [] = trackArticulators( file )
%trackVelTT Get time series for velum and tongue tip
%	file	name of the file (with or without .avi extension)
%   Detailed explanation goes here

no_ext = isempty(strfind(file, '.avi'));
if no_ext
	filename = file;
	file = strcat(filename,'.avi');
else
	[~, filename, ~] = fileparts(file);
end

disp('Click in the LABIAL region.');
ts_lab = trackRadialRegion(file, 'LabialTimeSeries');

disp('Click in the VELUM region.');
ts_vel = trackVelum(file);

disp('Click in the TONGUE TIP region.');
ts_tt = trackRadialRegion(file, 'TongueTipTimeSeries');

disp('Click in the TONGUE BODY region.');
ts_dor = trackRadialRegion(file, 'TongueBodyTimeSeries');

disp('Click in the TONGUE ROOT region.');
ts_root = trackRadialRegion(file, 'TongueRootTimeSeries', 4);

maskComposite = ts_lab.mask + ts_vel.mask + ts_tt.mask + ts_dor.mask + ts_root.mask;
maskedCompositeImage = ts_lab.meanImage + (20*(maskComposite./max(max(maskComposite))));
imagesc(maskedCompositeImage);

loadArticulatorsIntoMViewRT(filename);

end

