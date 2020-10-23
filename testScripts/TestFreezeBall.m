%% TestFreezeBall
% Created February 2016 : edit March 2016
% Student Number: 15102411
%
%
% DESCRIPTION
%     This test script tests whether an ellipse with long-short axis of 0.6 can
%     be constructed to surround the lesions. The script makes use of the all
%     the previous functions, but especially the FindOptimalCoordinatees
%     function which outputs a myOptGrid structure, which contains all the
%     useful calculations from that function to be used to find the optimal
%     release coordinates and size of the ice ball.
% 
%
%
%
%% Clean workspace and add paths
clear all;
close all;
clc;

%% Check Paths
addpath(genpath('../data'),'../src','../files');

%% Test function
% add names for simplicity
names = {'PhantomLesionMRContourPoints.mat',
    'PhantomMRContourPoints.mat',
    'PatientLesionMRContourPoints.mat',
    'PatientProstateMRContourPoints.mat'};

testCase = {'MRI-Anon','MRI-Phantom','TRUS-Anon','TRUS-Phantom'};

% switch 1 is the phantom data, switch 2 is the patient data
switch 1
    case 1
        %% Load Grid Poitns
%         tic
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
        load('../data/PhantomPointData/PhantomTRUSPoints.mat');
        
        % to have in familar format and scale to MRI phantom
        myUSPoints.data = [US_points(:,1)/2, US_points(:,2)/2 ,US_points(:,3)];
               
        % Resample the points
        myNewPoints = ResampleContourPoints(myMRProPoints,25);
        
        % Create a mask
        myMasks = VoxelizeContours(myNewPoints,myMRImage,'Sum');
               
        % get ICP Data
        myICPData = RegisterLMICP(myMasks,myUSPoints);
        
        % find the optimal grid coordinates
        [myOptGrid,~] = FindOptimalGridCoords(myMRPoints,myICPData,...
            gridPoints,myUSImage);
        
        % find the freezeBall coordinates
        [myEllipsePoints] = FreezeBalls(myOptGrid,myUSImage,'Print');
        
%         disp('Time to load and run everything')
%         toc
       
    case 2
         %% PAtient Data
         tic
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
        DisplayMRIContourPointsIn3D(myMRPoints);
        % myPoints2 = LoadMRIContourPoints(names{1});
        
        % Resample the points
        myNewPoints = ResampleContourPoints(myMRProPoints,25);
        
        % Create a mask
        myMasks = VoxelizeContours(myNewPoints,myMRImage,'Sum');
                
        % get ICP Data
        myICPData = RegisterLMICP(myMasks,myUSPoints,'Print');
        
        % find the optimal grid coordinates
        [myOptGrid,~] = FindOptimalGridCoords(myMRPoints,myICPData,...
            gridPoints,myUSImage);
        
        % find the freezeBall coordinates
        [myEllipsePoints] = FreezeBalls(myOptGrid,myUSImage)
        
        % uncomment to time
        disp('Time to load and run everything')
        toc
end