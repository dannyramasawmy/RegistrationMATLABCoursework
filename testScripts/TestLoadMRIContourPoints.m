%% TestLoadMRIContourPoints
% Created February 2016
% Student Number: 15102411
%
% 
% DESCRIPTION: 
% The aim of this task is to load the contour points for the 
% MRI images, there are four data sets to load, and there are two for the 
% lesions and prostate of the phantom and two for the lesion and prostate 
% for the patient data. This need to be separated into the different parts 
% if possible. 
 

%% Clean workspace and add paths
clear all;
close all;
clc;

%% Check Paths
addpath('../data','../src','../files');

% set up
names = {'PhantomLesionMRContourPoints.mat',
    'PhantomMRContourPoints.mat',
    'PatientLesionMRContourPoints.mat',
    'PatientProstateMRContourPoints.mat'};

%% Test from looping through each one to load
for j = 1:4
    
    % load myPoints object
    myPoints = LoadMRIContourPoints(names{j})
    
    % Plotting
    figure(1),
    %
    length(myPoints);
    
    % plot the points
    for i = 1:length(myPoints)
        
        % overlay plot
        hold on
        
        % open figure 1
        figure(1)
        
        % subplot
        subplot(2,2,j)
        
        % plot the data points in 3d with circles
        plot3(myPoints(i).data(:,1),myPoints(i).data(:,2),...
            myPoints(i).data(:,3),'o')
        
        % title the subplot
        title(names{j}(1:end-4))
    end
    
    % axis labels
    xlabel('X - axis')
    ylabel('Y - axis')
    zlabel('Z-axis')
    
    % add  a grid
    grid on
    
    % pause to allow user to see output
    pause;
    
end

%% Test 2 : no input arguments
myPoints = LoadMRIContourPoints()

%% Test 3: multiple arguments
myPoints = LoadMRIContourPoints(1,2,3);

%% Test 4: incorrect arguments
myPoints = LoadMRIContourPoints('bleepbloop');
