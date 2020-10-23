%% TestDisplayMRIwithContours
% Created February 2016: edit March 2016
% Student Number: 15102411
%
%
% DESCRIPTION:
%   This script is to test displaying an mri volume slice with mr contour
%   points, the contour points must relate to the image. The overlayed
%   points can be in different styles thicknessess and colours.
%


%% Clean workspace and add paths
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

%% Load Data
myImage = LoadDICOMVolume(testCase{2});

% load contour point data
myPoints = LoadMRIContourPoints(names{1});
myPoints(4:6) = LoadMRIContourPoints(names{2});

%% specifify plotting things
lineWidth = [1 1 1 1 1 1];

% colors RGB
color = [   0 1 0 ;     % first object
    1 1 0 ;     % second object
    0 1 1 ;     % 3rd
    1 0 1 ;     % 4th
    1 0 0 ;     % 5th
    0 0 1   ];  % 6th

% dot-star-circle-square-plus-hexagon
pointStyle = '-*-*--';

%% Test 1 : can I plot everything
for slice = 1:100
    
    % plot the figure
    plotHandle = DisplayMRIwithContours(myImage,myPoints,slice,lineWidth,...
        color,pointStyle);
    % draw the image
    drawnow;
    % wait for user input
    pause;
    % close image
    close all
end

%% Test 2 : no extra inputs
% set slice
slice = 12;
% plot
plotHandle = DisplayMRIwithContours(myImage,myPoints,slice);

%% Test 3 : bad myPoint data
DisplayMRIwithContours(myImage,[1 ;1],slice);

%% Test 4 : Slice out of bounds
slice = 160;
DisplayMRIwithContours(myImage,[1 ;1],slice);




