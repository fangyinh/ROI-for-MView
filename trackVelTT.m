function [] = trackVelTT( file )
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

disp('Click in the VELUM region.');
trackVelum(file);

disp('Click in the TONGUE TIP region.');
trackTongueTip(file);

loadIntoMViewRT(filename);

end

