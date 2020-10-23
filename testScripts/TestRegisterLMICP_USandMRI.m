%% TestResgisterLMICP_USandMRI
% Created February 2016  : edit March 2016
% Student Number: 15102411
%
%
% DESCRIPTION:
% This test script checks if the ICP algrothim converges, and sees the
% results of the starting and ending points of the algorith. It does this
% for the MRI points to MRI surface and the US Points to the MRI surface
% from myMasks
%
% The DSC coefficient is calculated for this case
%

%% Clean workspace and add paths
clear all;
close all;
clc;

%% Check Paths
addpath('../data','../src','../files');

%% Test function
% add names for simplicity

testCase = {'MRI-Anon','MRI-Phantom','TRUS-Anon','TRUS-Phantom'};

names = {'PhantomLesionMRContourPoints.mat',
    'PhantomMRContourPoints.mat',
    'PatientLesionMRContourPoints.mat',
    'PatientProstateMRContourPoints.mat'};

% switch 1 is the LMICP of MRI points to surface
% switch 2 is the ultrasound points and DSC coefficient
switch 2
    case 1
        %% Load Data and resample
        
        % Load Image
        myImage = LoadDICOMVolume(testCase{2});
        
        % Load Contour Points
        myUSPoints = LoadMRIContourPoints(names{2});
        
        % myPoints2 = LoadMRIContourPoints(names{1});
        
        % Resample the points
        myNewPoints = ResampleContourPoints(myUSPoints,25);
        
        % Create a mask
        myMasks = VoxelizeContours(myNewPoints,myImage,'Sum');
        
        % Interpolate the mask
        % myInterMask = InterpolateBinaryImage(myMasks,'Linear');
        
        % Give it the mask
        imMask = myMasks.volume;
        
        %% Figure
        figure(1)
        isosurface(imMask)
        hold on
        for i = 1:3
            plot3(myNewPoints(i).data(:,1),myNewPoints(i).data(:,2),...
                myNewPoints(i).data(:,3),'o')
        end
        
        
        %% Both Registrations
        % myICPData(1) = RegisterICP(myMasks,myNewPoints,'Print');
        
        % give it the myPoints
        myICPData = RegisterLMICP(myMasks,myNewPoints,'Print')
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55
    case 2  % This the registration of the US points for the Phantom
        for icpFun = 1:2
            %% Load Data and resample
            
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
            
            % Try register phantom US to MRI
            
            if icpFun == 1;
                myICPData(icpFun) = RegisterLMICP(myMasks,myUSPoints)
            else
                myICPData(icpFun) = RegisterICP(myMasks,myUSPoints);
            end
            %% Find US Points
            myUSImage = LoadDICOMVolume(4);
            
            % For searching for the mid points
            %         for i = 1:size(myUSImage.volume,3)
            %             figure(1)
            %             imagesc(myUSImage.volume(:,:,i))
            %             colormap bone
            %             title(num2str(i))
            %             i
            %             drawnow; pause;
            %         end
            
            % Prostate US lesion mid Points
            centPoints = [234 172 29.5;         % Lesion 1
                334 174 37;                   % lesion 2
                310 169 16.5];                   % lesion 3
            
            % scale the US centre points
            centPoints = [centPoints(:,1)/2, centPoints(:,2)/2,...
                centPoints(:,3),ones(3,1)]';
            
            % transform them into MRI Image
            transCentPoints = (myICPData(icpFun).T*centPoints)';
            
            % load the lesion MRI points
            myLesionPoints = LoadMRIContourPoints(names{1});
            % Resample the points
            myNewLPnts = ResampleContourPoints(myLesionPoints,25);
            % Create a mask
            lesionMask = VoxelizeContours(myNewLPnts,myImage,'Sum');
            
            
            % Put all lesions into one matrix
            tempDat2 = [myLesionPoints(1).data ; myLesionPoints(2).data;...
                myLesionPoints(3).data];
            
            % Phantom Points
            phantomProstate = [myPoints2(1).data ; myPoints2(2).data ; myPoints2(3).data];
            %% Find Lesion MidPoints
            % temporary matrix
            tmp = [];
            for i = 1:3
                % find center points of mri lesions
                tmp = [ tmp ;mean(myLesionPoints(i).data)];
                
                % use the structure of mri lesions to make US lesion volumes
                tempLesion(i).data = myLesionPoints(i).data-...
                    repmat(tmp(i,:),length(myLesionPoints(i).data),1)+...
                    repmat(transCentPoints(i,1:3),length(myLesionPoints(i).data),1);
            end
            
            % US lesion points
            usLesionPoints = [tempLesion(1).data ; tempLesion(2).data ;
                tempLesion(3).data];
            
            % centre points of
            lesionMidPoints = tmp;
            
            %% Calculate the mesaures
            % Lesion 1:3
            myICPData(icpFun).TRE = sum((lesionMidPoints-transCentPoints(:,1:3)).^2,2)
            
            % We have Lesion Mask - need ot make a second
            for i = 1:3
                tempLesion(i).data(:,3) = round(tempLesion(i).data(:,3));
            end
            % Resample the points
            myNewUSLPnts = ResampleContourPoints(tempLesion,25);
            
            % Create a mask for the US lesion points
            lesionUSMask = VoxelizeContours(myNewUSLPnts,myImage,'Sum');
            
            % Calculate volumes
            % initalise
            overlapMask = lesionUSMask;
            overlapMask.volume = lesionUSMask.volume.*lesionMask.volume;
            % volumes
            volMRandUSL = CalculateOrganVolume(overlapMask);
            volUSL = CalculateOrganVolume(lesionUSMask);
            volMRL = CalculateOrganVolume(lesionMask);
            myICPData(icpFun).DSC = 2*volMRandUSL/(volUSL+volMRL);
            
            
            
            %% Plotting Everything
            
            % Plot all the US points along with the masks before and after
            % registration
            figure,
            
            % all the points
            subplot(1,2,1)
            
            % mask thats transparent
            isosurface(myMasks.volume), alpha(0.1)
            hold on
            
            plot3(phantomProstate(:,1),phantomProstate(:,2),phantomProstate(:,3),'.g')
            % origional US poitns
            plot3(myUSPoints.data(:,1),myUSPoints.data(:,2),...
                myUSPoints.data(:,3),'.r')
            % prostate USpoints transformed
            plot3(myICPData(icpFun).data(:,1),myICPData(icpFun).data(:,2),...
                myICPData(icpFun).data(:,3),'.b')
            % lesions MRI
            plot3(tempDat2(:,1),tempDat2(:,2),tempDat2(:,3),'y.')
            % plot lesions for US Data
            plot3(usLesionPoints(:,1),usLesionPoints(:,2),usLesionPoints(:,3),'r.')
            % centres
            plot3(transCentPoints(:,1),transCentPoints(:,2),transCentPoints(:,3),'r*')
            % centers before transform
            plot3(centPoints(1,:),centPoints(2,:),centPoints(3,:),'b*')
            
            % Legend
            legend('Transparent Mask','MRi Prostate Contour',...
                'US Points','Transformed US Points','Lesions MRI',...
                'US Lesions','US Transformed CP','US Lesion CPs')
            hold off
            % Labels
            xlabel('X'),ylabel('Y'),zlabel('Z')
            % grid
            grid on
            title('Plot of US points before and after registration and Transform')
            
            subplot(1,2,2)
            isosurface(myMasks.volume), alpha(0.1)
            hold on
            isosurface(lesionMask.volume), alpha(0.1)
            % lesions MRI
            plot3(tempDat2(:,1),tempDat2(:,2),tempDat2(:,3),'y.')
            % plot lesions for US Data
            plot3(usLesionPoints(:,1),usLesionPoints(:,2),usLesionPoints(:,3),'r.')
            % centres
            plot3(transCentPoints(:,1),transCentPoints(:,2),transCentPoints(:,3),'b*')
            
            % Legend
            legend('Transparent Mask','Lesion Mask','Lesions MRI','US Lesions','US Transformed CP')
            hold off
            % Labels
            xlabel('X'),ylabel('Y'),zlabel('Z')
            % grid
            grid on
            % title
            title('Plot of the lesion overlap for the US and MRI contour points')
            axis([0 140 0 140 0 50 ])
            
            % Plotting the Lesion Volumes after they are masked
            figure,
            p1 = patch(isosurface(lesionMask.volume));
            alpha(1);
            p2.FaceColor = 'red';
            p2.EdgeColor = [0 1 0];
            
            hold on
            p = patch(isosurface(lesionUSMask.volume));
            alpha(0.1);
            p.FaceColor = 'yellow';
            p.EdgeColor = [1 1 0];
            legend('lesion MRI','Lesion US');
            title('Overlay of MRI Lesion mask, and created US lesion Mask');
        end
end








