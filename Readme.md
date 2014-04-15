# Region of Interest (ROI) Analysis for MViewRT

## What this code is for

This code is used to convert rtMRI videos of vocal tract movement into a format 
that MViewRT can use. You specify regions of interest (tongue tip, velum, etc.) 
and this code gets it MViewRT-ready.

## Who should use this code

This code was written for the SPAN group at the University of Southern 
California. Anyone can use it, but it's only useful if you have access to rtMRI 
videos and the MViewRT software.

## How to use this code

It's not too challenging to start doing region of interest analysis on your 
vocal tract videos. You need MATLAB (preferably with the image processing 
toolbox), the MViewRT software, plus the video (.avi) and audio (.wav) files of 
the video you want to analyze. 

1. In MATLAB, navigate into a folder that contains both the .avi and .wav files 
for your video. The files should have the same name, just different extensions.
2. Pass the name of the video file into the trackVelTT function:
'''
>> trackVelTT(filename)
'''
3. Click on a spot near the velum (preferably along the top edge, between the 
middle and the pharynx).
4. Wait until the grayscale image disappears and reappears again; now, click on 
a spot near the tongue tip.
5. Be patient, and the MViewRT should open automatically with the file you 
selected and time series for the velum and tongue tip. Do your MViewRT stuff.

In the process of making the time series, trackVelTT.m saves the unfiltered time
series, the filtered time series, and a bunch of other useful information in 
.mat files under a new folder that takes its name from the file name you passed 
into the function. Now, closing MViewRT does not get rid of the time series. 
When you want to investigate the video again, you can call
'''
>> loadIntoMViewRT(filename)
'''