%% TestCalculateOrganVolume
% Created February 2016
% Student Number: 15102411
%
% 
% DESCRIPTION:
%   The objects have been made into isotropic masks from before, now the
%   aim is to estimate the organ volume from each. This can be done
%   directly from the contour points or can be got from summing the mask
%   and multiplying by the voxel volume
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

% Load Image
myImage = LoadDICOMVolume(testCase{2});

% Load Contour Points
myPoints = LoadMRIContourPoints(names{2});
myPoints(4:6) = LoadMRIContourPoints(names{1});

% Resample the points
myNewPoints = ResampleContourPoints(myPoints,20);

% Create a mask
myMasks = VoxelizeContours(myNewPoints,myImage);

% Interpolate the mask
myInterMask = InterpolateBinaryImage(myMasks,'Linear');

%% TEST 1 : Calculate organ volume form the masks
myVolume = CalculateOrganVolume(myInterMask)
% phanotm volume orders
% order [ prostate, left sem ves, right semi ves, lesion, lesion,lesion]

%% TEST 2 : Calculate organ volumes from the contour poitns
% just the total prostate and seminal vesicles
myVolume2 = CalculateOrganVolume(myNewPoints(1:3),[0.4 0.4 1],'Sum')

%% TEST 3 :  Calculate lesion volumes
% just the total prostate and seminal vesicles
myVolume3 = CalculateOrganVolume(myNewPoints(4:6),[0.4 0.4 1],'Sum')

%% TEST 4: calculate lesion volumes with points
% all objects
myVolume4 = CalculateOrganVolume(myNewPoints,[0.4 0.4 1])
% phanotm volume orders
% order [ prostate, left sem ves, right semi ves, lesion, lesion,lesion]




%% =======================================================================
% Test patient
% Clean workspace and add paths
clear all;
close all;
clc;

% Check Paths
addpath('../data','../src','../files');

% Test function
% add names for simplicity
names = {'PhantomLesionMRContourPoints.mat',
    'PhantomMRContourPoints.mat',
    'PatientLesionMRContourPoints.mat',
    'PatientProstateMRContourPoints.mat'};
testCase = {'MRI-Anon','MRI-Phantom','TRUS-Anon','TRUS-Phantom','blue'};

%% Load Data and resample

% Load Image
myImage = LoadDICOMVolume(testCase{1});

% Load Contour Points
myPoints = LoadMRIContourPoints(names{3});
myPoints(2) = LoadMRIContourPoints(names{4});

% Resample the points
myNewPoints = ResampleContourPoints(myPoints,20);

% Create a mask
myMasks = VoxelizeContours(myNewPoints,myImage);

% Interpolate the mask
myInterMask = InterpolateBinaryImage(myMasks,'Linear');

%% TEST 1 : Calculate organ volume form the masks
myVolume4 = CalculateOrganVolume(myInterMask)
% patient volume orders
% order [ lesion, prostate]

%% TEST 2 : Calculate organ volumes from the contour poitns
% just the total prostate and seminal vesicles
myVolume5 = CalculateOrganVolume(myNewPoints,[0.3906 0.3906 6.3])
% patient volume orders
% order [ lesion, prostate]




