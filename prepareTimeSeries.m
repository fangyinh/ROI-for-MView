function data = prepareTimeSeries( varargin )
%prepareTimeSeries Turn the time series into a struct that can be used in
%MView's FormatData function
%   varargin is a set of ArticulatorTimeSeries objects
%	data is a permutation of the intensity data

	nVarargs = length(varargin);
	data.fps = 0;

	for k = 1:nVarargs
		ts = varargin{k};
		
		fps = ts.framerate;
		if(data.fps == 0)
			data.fps = fps;
		end

		data.gest(k).name = ts.name;
		data.gest(k).location = [ts.x, ts.y];
		
		[numFrames, ~] = size(ts.vidMatrix);
		frames = 0:(numFrames-1); % 1 gets added in FormatData.m, so subtract it here (assuming the frames are 1-based instead of 0-based, I suppose)

		data.gest(k).frames = frames;
		times = frames ./ fps;
		data.gest(k).times = times;

		data.gest(k).Ismoothed = ts.ts_filt;
		data.gest(k).stimes = times;
	end

end

