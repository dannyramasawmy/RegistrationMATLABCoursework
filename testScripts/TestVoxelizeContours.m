%% TestVoxelizeContours
% Created February 2016 : edit March 2016
% Student Number: 15102411
%
%
% DESCRIPTION:
%   Voxelize contours, converts the resampled points into a binary image,
%   this is done using the poly to mask function. The reasmpled points come
%   from the ResampleContourPoints function, which returns an object like
%   myPoints with fields.data and .name.
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

%% Load Data and resample
% load image
myImage = LoadDICOMVolume(testCase{2});
% load myPoints
myPoints = LoadMRIContourPoints(names{2});
% resample contours
myNewPoints = ResampleContourPoints(myPoints,200);
% cummulative mask
myMasks = VoxelizeContours(myNewPoints,myImage,'Sum');
% single mask
myMasks2 = VoxelizeContours(myNewPoints,myImage);

%% Test 1 - all points together
figure(1)
isosurface(myMasks.volume)
% add labels
xlabel('x'),ylabel('y'),zlabel('z');
title('Multi points-input - single output mask')
colormap copper
grid on

%% Test 2 - seperate ones
figure(2)
% specify colormaps
col = {'copper','gray'};

% loop over each dimensions
isosurface(myMasks2(1).volume)

% add labels
xlabel('x'),ylabel('y'),zlabel('z');

% title
title('Multi points-input - multi output-masks')
%
colormap(col{1});
grid on

%% Test 3- Lesions
% Load Data and resample
% load image
myImage = LoadDICOMVolume(testCase{2});
% load myPoints
myPoints = LoadMRIContourPoints(names{1});
% resample contours
myNewPoints = ResampleContourPoints(myPoints,200);
% cummulative mask
myMasks = VoxelizeContours(myNewPoints,myImage,'Sum');

figure(3)
% loop over each dimensions
isosurface(myMasks.volume)

% add labels
xlabel('x'),ylabel('y'),zlabel('z');

% title
title('Multi points-input - single out lesions')

% add grid
grid on