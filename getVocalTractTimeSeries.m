function [ ] = getVocalTractTimeSeries( filename )
%getVocalTractTimeSeries 
%   outputs x y coordinates to a tab-delimited text file

% Video
vr = VideoReader(filename);
framerate = vr.FrameRate;
vidMatrix = vr2Matrix(vr);

% Get Analysis Location
g = figure;
stdImage = reshape(std(vidMatrix,1),68,68);
imagesc(stdImage)
colormap gray
[x, y] = ginput();

[~, name, ~] = fileparts(filename);
dir = name;
[status, ~, messageid] = mkdir(dir);
if status==0
	if strcmp(messageid,'MATLAB:MKDIR:DirectoryExists') == 0
		disp('Crash!');
		return
	else
		disp(strcat(['Overwriting directory ' dir]));
	end
end
print(g,'-dpng',strcat(dir,'/stdDevImage'));
close();
fout = strcat(dir,'/vocaltractpoints.txt');

% NEXT: get name for fout

x = round(x);
y = round(y);

dlmwrite(fout, [x y], '\t');
disp(strcat(['Saved vocal tract points to ' fout]));

end

