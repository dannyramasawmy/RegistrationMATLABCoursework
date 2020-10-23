%% TestDisplayMRIContourPointsIn3D
% Created February 2016: edit March 2016
% Student Number: 15102411
%
% 
% DESCRIPTION
% 
% This test script checks if the function can cope with incorrect
% inputs, and plot any number of contour points in 3D. With the user
% defining the thickenss, colours and point styles as extra input
% arguments.
%
%
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
    
% Load point data
myPoints = LoadMRIContourPoints(names{2});
myPoints(4:6) = LoadMRIContourPoints(names{1});

%% Test 1 : can I plot everything

% specifify 
lineWidth = [0.1 0.1 0.1 0.2 0.2 0.3];

% colors RGB
color = [   0 0 0 ;     % first object
            1 1 0 ;     % second object
            0 1 1 ;     % 3rd
            1 0 1 ;     % 4th
            1 0 0 ;     % 5th
            0 0 1   ];  % 6th
        
% dot-star-circle-square-plus-hexagon
pointStyle = '.*os+h';

% plot function
plotHandle = DisplayMRIContourPointsIn3D(myPoints,lineWidth,color,pointStyle);

% can give it a title
title('MRI Contour Points')


%% Test 2: incorrect input arguments
DisplayMRIContourPointsIn3D(1);

%% Test 3: missing input arguments in varargin
plotHandle = DisplayMRIContourPointsIn3D(myPoints,lineWidth,[],pointStyle);

%% Test 4: no extra input arguments
plotHandle = DisplayMRIContourPointsIn3D(myPoints);

%% Test 5: no extra input arguments
plotHandle = DisplayMRIContourPointsIn3D(myPoints,[1 2 3],[],'o');
