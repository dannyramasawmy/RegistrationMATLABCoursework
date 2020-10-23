%% TestResampleContourPoints
% Created February 2016 : edit March 2016
% Student Number: 15102411
%
% DESCRIPTION:
% This scripts tests the resample contour point function, by upsampling the
% points witha user defined input. It fits a circular spline to the ocntour
% points on the slices and can be resampled upto approximately 300 points.
% If the user wants more than 300 per slice then there are repeated points.
% 

%% Clean workspace 
clear all;
close all;
clc;

%% Check Paths
addpath('../data','../src','../files');

%% Test function
% add names for simplicity
names = {'PhantomLesionMRContourPoints.mat',
        'PhantomMRContourPoints.mat',
        'PatientLesionMRContourPoints.mat',
        'PatientProstateMRContourPoints.mat'};
testCase = {'MRI-Anon','MRI-Phantom','TRUS-Anon','TRUS-Phantom','blue'};

% load the image and data
% Load Data
myImage = LoadDICOMVolume(testCase{2});
myPoints = LoadMRIContourPoints(names{2});
myPoints(4:6) = LoadMRIContourPoints(names{1});

% plot just contours before resampling
plotHandle = DisplayMRIContourPointsIn3D(myPoints);

%% Test1 = Resample the poitns
% resample points for 6 objects
myNewPoints = ResampleContourPoints(myPoints,100);

% display resampled points 
DisplayMRIContourPointsIn3D(myNewPoints);
title('Test 1 : resampled points all objects')

%% Test 2 = Resample with bad inputs
% resample points for 6 objects
myNewPoints = ResampleContourPoints(myPoints,'hello');

% display resampled points 
DisplayMRIContourPointsIn3D(myNewPoints);
title('Bad Inputs')

%% Test 3 : no extra inputs
% resample points for 6 objects
myNewPoints = ResampleContourPoints(myPoints);

% display resampled points 
DisplayMRIContourPointsIn3D(myNewPoints);
title('No extra Inputs')


%% View a slice of points
% Set through slices

for slice = 1:length(myImage.volume(1,1,:));
    plotHandle = DisplayMRIwithContours(myImage,myNewPoints,slice,[],[],...
        '******');
    drawnow;
    pause;
    close all
end





