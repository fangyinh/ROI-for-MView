# Region of Interest (ROI) Analysis for MViewRT

## What this code is for

This code is used to extract gestural information from rtMR videos using a
Region of Interest analysis.

## Who should use this code

This code was written for the SPAN group at the University of Southern 
California. Anyone can use it, but you should tell us when you do.

## How to use this code

It's not too challenging to start doing region of interest analysis on your 
vocal tract videos. You need MATLAB (preferably with the image processing 
toolbox), the MViewRT software, plus the video (.avi) and audio (.wav) files of 
the video you want to analyse.

If you want to skip reading and get straight to the code, check out the demo 
files: [demo.m](demo.m) and [demo2.m](demo2.m)

### Getting gestural time series

1. In MATLAB, navigate to a folder that contains both the .avi and .wav files 
for your video. The files should have the same name (aside from their 
extensions).
2. Create a new VocalTract object with the file name. If the file is named 
"cool_video_2.avi", you type:

        >> vt = VocalTract('cool_video_2.avi')
	
3. Get information about the vocal tract by calling the init() function:

		>> vt.init();
		
4. A grayscale image will appear. Click on a point at the front of the lips, 
then a point on the back curve of the tongue (often near the velum), and finally
near the larynx.
5. A new image will appear with a line marking the midline of the vocal tract.
Click a point on that line near the front of the lips, then the back of the 
lips, then the front and back of the tongue tip, and so on, following the 
instructions MATLAB gives on-screen.

### Extracting the gestures using MViewRT

WARNING: MViewRT requires the MViewRT and melba packages. If you use the melba
package for TaDA, you will need to get a new version from me. See contact
information below.

1. Assuming you followed the steps above, load the extracted gestures into 
MViewRT by calling:

		>> VocalTract.loadIntoMViewRT('cool_video_2.avi');
		
2. MViewRT will open, followed by a dialogue box. In place of <SCREEN>, type the
name of your file (in this case, 'cool_video_2'). Do not use quotation marks.
Click "OK".
3. On the MViewRT toolbar, navigate to MVIEWRT and click 'Auto Update'.
4. There is a gray-ish box containing audio information (above the box labeled
AUDIO). Drag the left and right edges of that box inward until the gray only
covers your current frames of interest.
5. On the lower-right side of MViewRT, you will find the time series for each
articulator. Gestural constrictions occur at the minima of those time series.
When you right-click (Ctrl+click on a Mac) on a minimum, MViewRT labels that
gesture.
6. Navigate to Labels > Export Labels... to save your labels to a .lab file.

### Preparing labels for the PDF GUI

1. Find the .lab file containing the gesture labels in your current directory.
Open it in MATLAB.
2. .lab files are tab-delimited. The second column TRAJ contains the gesture
label. The third column, COMMENT, is currently empty. For each row, insert the
Arpabet symbol which best describes the gesture into the COMMENT column.
3. Save the .lab file.
4. Send the relevant label information to a .txt file by calling:

		>> VocalTract.convertLabelsForGUI('cool_video_2.avi');

5. Edit the 'cool_video_2.txt' file as necessary to make it usable in the PDF 
GUI.

## Contact

To ask questions, report bugs, or request features, email: 
reedblaylock (at) gmail (dot) com.