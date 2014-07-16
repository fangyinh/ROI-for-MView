%% Prepare filename variable

filename = 's2_study6_5.avi'; % The name of whatever .avi file you plan to use.

%% Get and fill VocalTract object
% Articulations are extracted from multiple overlapping Regions of Interest. See demo2.m for extracting the information from a single place of articulation.

vt = VocalTract(filename);
vt.init();

%% Save VocalTract to a file

vt.save();

%% Load data into MViewRT

% VocalTract.loadIntoMViewRT(filename);

%% Prepare data for PDF GUI

% VocalTract.convertLabelsForGUI(filename);
