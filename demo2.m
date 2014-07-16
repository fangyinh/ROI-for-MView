%% Prepare filename variable

filename = 's2_study6_5.avi';

%% Get vocal tract information about tongue tip and tongue root only
% Articulations are extracted from a single place of articulation, determined by the user's click. See demo.m for extracting all the information about an articulator.

vt = VocalTract(filename);
vt.setArticulator({'TT', 'TR'});

%% Save VocalTract to a file

vt.save();

%% Load data into MViewRT

% VocalTract.loadIntoMViewRT(filename);

%% Prepare data for PDF GUI

% VocalTract.convertLabelsForGUI(filename);

