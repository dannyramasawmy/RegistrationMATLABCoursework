%% TestFindOptimalGridCoords
% Created February 2016 : edit March 2016
% Student Number: 15102411
%
%
% DESCRIPTION
% This script registers the US points for the Patient and the Phantom to
% the surface of the MRI, it also displays the USimage, with the optimal
% hole positions step by step, with the contour points overlayed.
% 
%
%
%
%% Clean workspace and add paths
clear all;
close all;
clc;

%% Check Paths
addpath('../data','../src','../files','../data/PhantomPointData',...
    '../data/PatientPointData');

%% Test function
% add names for simplicity
names = {'PhantomLesionMRContourPoints.mat',
    'PhantomMRContourPoints.mat',
    'PatientLesionMRContourPoints.mat',
    'PatientProstateMRContourPoints.mat'};

testCase = {'MRI-Anon','MRI-Phantom','TRUS-Anon','TRUS-Phantom'};

% switch 1 = phantom, switch 2 is patient
switch 1
    case 1
%         clear all, close all
        %% Load Grid Poitns
        load('../data/PhantomPointData/PhantomGridPoints.mat') % returns gridPoints
        
        % Load Data and resample
        
        % Load Image
        myMRImage = LoadDICOMVolume(testCase{2});
        myUSImage = LoadDICOMVolume(testCase{4});
        % Load Contour Points
        myMRProPoints = LoadMRIContourPoints(names{2});
        myMRPoints = LoadMRIContourPoints(names{1});
%         myMRConPoints(4:6) = myMRProPoints; 

        % Load ultrasound points
        load('../data/PhantomPointData/PhantomTRUSPoints.mat')
        
        % to have in familar format and scale to MRI phantom
        myUSPoints.data = [US_points(:,1)/2, US_points(:,2)/2 ,US_points(:,3)];
        
        % myPoints2 = LoadMRIContourPoints(names{1});
        
        % Resample the points
        myNewPoints = ResampleContourPoints(myMRProPoints,25);
        
        % Create a mask
        myMasks = VoxelizeContours(myNewPoints,myMRImage,'Sum');
        
        
        % Interpolate the mask
        % myInterMask = InterpolateBinaryImage(myMasks,'Linear');
        
        % get ICP Data
        myICPData = RegisterLMICP(myMasks,myUSPoints)
        
        % find th eoptimal grid coordinates
        [myOptGrid,~] = FindOptimalGridCoords(myMRPoints,myICPData,...
            gridPoints,myUSImage,'Print')
        
        %% PAtient Data
    case 2
%         clear all, close all
        % Load Grid Poitns
        load('../data/PatientPointData/PatientGridPoints.mat') % returns gridPoints
        
        myMRImage = LoadDICOMVolume(testCase{1});
        myUSImage = LoadDICOMVolume(testCase{3});
        % Load Contour Points
        myMRProPoints = LoadMRIContourPoints(names{4});
        myMRPoints(1) = LoadMRIContourPoints(names{3});
%         myMRConPoints(2) = LoadMRIContourPoints(names{4});
        
        
        % Load ultrasound points
        load('../data/PatientPointData/PatientTRUSUSPoints.mat')
        
        % to have in familar format and scale to MRI phantom
        sf = 0.1613/0.3609;
        sz = 1.9579/3;
        myUSPoints.data = [US_points(:,1)*sf+100, US_points(:,2)*sf+200 ,US_points(:,3)*sz];
        DisplayMRIContourPointsIn3D(myMRPoints)
        % myPoints2 = LoadMRIContourPoints(names{1});
        
        % Resample the points
        myNewPoints = ResampleContourPoints(myMRProPoints,25);
        
        % Create a mask
        myMasks = VoxelizeContours(myNewPoints,myMRImage,'Sum');
        
        
        % Interpolate the mask
        % myInterMask = InterpolateBinaryImage(myMasks,'Linear');
        
        % get ICP Data
        myICPData = RegisterLMICP(myMasks,myUSPoints,'Print')
        
        %%
        % find th eoptimal grid coordinates
        [myOptGrid,~] = FindOptimalGridCoords(myMRPoints,myICPData,gridPoints,myUSImage,'Print')
end