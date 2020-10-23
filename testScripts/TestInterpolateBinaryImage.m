%% TestInterpolateBinaryImage
% Created February 2016 : March 2016
% Student Number: 15102411
%
%
% DESCRIPTION:
% The purpose of this function is to ake the voxel dimensions isotropic.
% They are isotropic in i and j and need to be made isotropic in z to make
% them more useable.
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

testCase = {'MRI-Anon','MRI-Phantom','TRUS-Anon','TRUS-Phantom','blue'};
tests = {'Test_1','Test_2','Test_3','Test_4'}

% choose test
switch tests{1}
    case 'Test_1'
        %% TEST 1 : Phantom Prostate,
        % load data
        myImage = LoadDICOMVolume(testCase{2});
        % load points
        myPoints = LoadMRIContourPoints(names{2});
        % resample points
        myNewPoints = ResampleContourPoints(myPoints,200);
        % get mask
        myMasks = VoxelizeContours(myNewPoints,myImage,'Sum');
        
        % interpolate the masks
        % linear interp
        tic
        myInterMask = InterpolateBinaryImage(myMasks,'Linear');
        toc
        
        % cubic interp
        tic
        myInterMask2 = InterpolateBinaryImage(myMasks,'Cubic');
        toc
        
        % Plot figures
        figure(1)
        % linear
        isosurface(myInterMask.volume)
        xlabel('x'),ylabel('y'),zlabel('z');
        title('linear mask')
        
        % cubic
        figure(2)
        isosurface(myInterMask2.volume)
        xlabel('x'),ylabel('y'),zlabel('z');
        title('cubic mask')
        
    case 'Test_2'
        %% Test 2: Phantom Lesions
        
        % load data
        myImage = LoadDICOMVolume(testCase{2});
        % load points
        myPoints = LoadMRIContourPoints(names{1});
        % resample points
        myNewPoints = ResampleContourPoints(myPoints,200);
        % get mask
        myMasks = VoxelizeContours(myNewPoints,myImage,'Sum');
        
        % interpolate the masks
        % linear interp
        tic
        myInterMask = InterpolateBinaryImage(myMasks,'Linear');
        toc
        
        % cubic interp
        tic
        myInterMask2 = InterpolateBinaryImage(myMasks,'Cubic');
        toc
        
        % Plot figures
        figure(3)
        % linear
        isosurface(myInterMask.volume)
        xlabel('x'),ylabel('y'),zlabel('z');
        title('linear mask')
        
        % cubic
        figure(4)
        isosurface(myInterMask2.volume)
        xlabel('x'),ylabel('y'),zlabel('z');
        title('cubic mask')
        
    case 'Test_3'
        %% TEST 3 : Phantom Prostate,
        % load data
        myImage = LoadDICOMVolume(testCase{2});
        % load points
        myPoints = LoadMRIContourPoints(names{2});
        % resample points
        myNewPoints = ResampleContourPoints(myPoints,200);
        % get mask
        myMasks = VoxelizeContours(myNewPoints,myImage,'Sum');
        
        % interpolate the masks
        % linear interp
        tic
        myInterMask = InterpolateBinaryImage(myMasks,'Linear');
        toc
        
        % cubic interp
        tic
        myInterMask2 = InterpolateBinaryImage(myMasks,'Cubic');
        toc
        
        % Plot figures
        figure(1)
        % linear
        isosurface(myInterMask.volume)
        xlabel('x'),ylabel('y'),zlabel('z');
        title('linear mask')
        
        % cubic
        figure(2)
        isosurface(myInterMask2.volume)
        xlabel('x'),ylabel('y'),zlabel('z');
        title('cubic mask')
        
    case 'Test_4'
        %% Test 4: Patient Prostate
        
        % load data
        myImage = LoadDICOMVolume(testCase{1});
        % load points
        myPoints = LoadMRIContourPoints(names{4});
        % resample points
        myNewPoints = ResampleContourPoints(myPoints,200);
        % get mask
        myMasks = VoxelizeContours(myNewPoints,myImage,'Sum');
        
        % interpolate the masks
        % linear interp
        tic
        myInterMask = InterpolateBinaryImage(myMasks,'Linear');
        toc
        
        % cubic interp
        tic
        myInterMask2 = InterpolateBinaryImage(myMasks,'Cubic');
        toc
        
        % Patient masks use alot of memory so are commented out     
        % Plot figures
        figure(5)
        % linear
%         isosurface(myInterMask.volume)
        xlabel('x'),ylabel('y'),zlabel('z');
        title('linear mask')
        
        % cubic
        figure(6)
%         isosurface(myInterMask2.volume)
        xlabel('x'),ylabel('y'),zlabel('z');
        title('cubic mask')
        
        %% Test 3: Patient Prostate
        
        % load data
        myImage = LoadDICOMVolume(testCase{1});
        % load points
        myPoints = LoadMRIContourPoints(names{3});
        % resample points
        myNewPoints = ResampleContourPoints(myPoints,200);
        % get mask
        myMasks = VoxelizeContours(myNewPoints,myImage,'Sum');
        
        % interpolate the masks
        % linear interp
        tic
        myInterMask = InterpolateBinaryImage(myMasks,'Linear');
        toc
        
        % cubic interp
        tic
        myInterMask2 = InterpolateBinaryImage(myMasks,'Cubic');
        toc
        
        % Patient masks use alot of memory so are commented out        
        % Plot figures
        figure(7)
        % linear
%         isosurface(myInterMask.volume)
        xlabel('x'),ylabel('y'),zlabel('z');
        title('linear mask')
        
        % cubic
        figure(8)
%         isosurface(myInterMask2.volume)
        xlabel('x'),ylabel('y'),zlabel('z');
        title('cubic mask')
end