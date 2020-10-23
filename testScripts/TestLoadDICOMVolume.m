%% TestLoadDICOMVolume
% Created February 2016, edit March 2016
% Student Number: 15102411
% 
% DESCRIPTION
% For computing foundations MATLAB 2015/2016 coursework, this test function
% loads images in the DICOM format. The images must be places in the specified
% search paths. ie ../data/ . However the function this test script calls
% has been limited to only allow folders on specific paths for two reasons. The
% first reason means that only the two MRI and two TRUS DICOM image volumes 
% specific for this task can be loaded, secondly to allow a quicker method for
% calling the specific volumes by providing an integer value. This can be 
% seen in the test script below.
%
% RELEVANT FUNCTIONS
% LoadDICOMVolume

%% Clean workspace
clear all;
close all;
clc;

%% add path to functions
addpath('../src');

%% Testing
warning off % the TRUS images have some problems
%==========================================================================
% Test case for no inputs
disp(['Test Case : LoadDICOMVolume()']);

% save variable
myImage = LoadDICOMVolume();

% display variable
disp(myImage);

pause;

%% ========================================================================
% Test case for single inputs
testCase = {0,1,2,3,4,...
    'MRI-Anon','MRI-Phantom','TRUS-Anon','TRUS-Phantom','blue'};

% For loop to iterate over every case
for idx = 1:length(testCase);
    
    % clear temporary variable
    clear myImage
    
    % display tst case
    disp(['Test Case : LoadDICOMVolume(',num2str(testCase{idx}),')']);
    
    % save variable
    myImage = LoadDICOMVolume(testCase{idx});
    
    % display structure
    disp(myImage);
    
    % wait for user input
    pause;
end

%% =======================================================================
% Test case for multiple inputs
disp(['Test Case : LoadDICOMVolume(4,MRI-Anon)']);
 
% call
myImage = LoadDICOMVolume(4,'MRI-Anon');

% display answer
disp(myImage);




