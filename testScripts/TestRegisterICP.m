%% TestResgisterICP
% Created February 2016
% Student Number: 15102411
%
% DESCRIPTION:
% This test script checks if the ICP algrothim converges, and sees the
% results of the starting and ending points of the algorith. It does this
% for the MRI points to MRI surface and the US Points to the MRI surface
% from myMasks
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

testCase = {'MRI-Anon','MRI-Phantom','TRUS-Anon','TRUS-Phantom'};

%% Load Data and resample
% switch = 1 is the mri points to mir surface prostate, 2 is US points

switch 2
    case 1
        % Load Image
        myImage = LoadDICOMVolume(testCase{2});
        
        % Load Contour Points
        myPoints = LoadMRIContourPoints(names{2});
        
        % myPoints2 = LoadMRIContourPoints(names{1});
        
        % Resample the points
        myNewPoints = ResampleContourPoints(myPoints,25);
        
        % Create a mask
        myMasks = VoxelizeContours(myNewPoints,myImage,'Sum');
        
        % Interpolate the mask
        % myInterMask = InterpolateBinaryImage(myMasks,'Linear');
        
        %%
        myICPData = RegisterICP(myMasks,myNewPoints,'Print');
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
    case 2
        % Load Data and resample
        
        % Load Image
        myImage = LoadDICOMVolume(testCase{2});
        
        % Load Contour Points
        myPoints2 = LoadMRIContourPoints(names{2});
        
        % Load ultrasound points
        load('../data/PhantomPointData/PhantomTRUSPoints.mat')
        
        % to have in familar format and scale to MRI phantom
        myUSPoints.data = [US_points(:,1)/2, US_points(:,2)/2 ,US_points(:,3)];
        
        
        % myPoints2 = LoadMRIContourPoints(names{1});
        
        % Resample the points
        myNewPoints = ResampleContourPoints(myPoints2,25);
        
        % Create a mask
        myMasks = VoxelizeContours(myNewPoints,myImage,'Sum');
        
        
        % Interpolate the mask
        % myInterMask = InterpolateBinaryImage(myMasks,'Linear');
        
        % Give it the mask
        % imMask = myMasks.volume;
        
        
        %%
        figure(2)
        isosurface(myMasks.volume)
        hold on
        plot3(myUSPoints.data(:,1),myUSPoints.data(:,2),myUSPoints.data(:,3),'o')
        % Display the US points
        % DisplayMRIContourPointsIn3D(myPoints)
        
        
        %% Try register phantom US to MRI
        myICPData = RegisterICP(myMasks,myUSPoints,'Print')
        
        %%
        transData =  (myICPData.T* ([myUSPoints.data,ones(length(myUSPoints.data),1)]'))';
        
        figure(5)
        isosurface(myMasks.volume)
        hold on
        plot3(myUSPoints.data(:,1),myUSPoints.data(:,2),myUSPoints.data(:,3),'o')
        plot3(transData(:,1),transData(:,2),transData(:,3),'r*')
        
end

