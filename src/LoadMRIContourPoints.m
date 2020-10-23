function [myPoints] = LoadMRIContourPoints(varargin)
% LoadMRIContourPoints
% Created February 2016 : edit March 2016
% Student Number: 15102411
%
% INPUT:
% The input to the function must be either the name of one of the files
% to be loaded, or a valid file path to a folder with the same data format
% as given in this coursework
%
% PROCESS:
% The function, checks the input arguments, it only excepts one input at a 
% time. The are two nested subfunctions, sortMe and filterMe. sortMe, extracts
% the data from the cell format used to store the contour points. filterMe
% sorts the extracted data into the individual objects, such as semicle vescle
% lesions and prostate.
%
% OUTPUT:
% The output is an object with two attributes, .data and .name field
%     myPoints.data	:	which contains the [x y z] coordinates for the 
%                         contour data. 
% 	myPoints.name	:	The filename associated with the loaded points, 
%                         for clarity
%
% DESCRIPTION:
% The aim of this task is to load the contour points for the 
% MRI images, there are four data sets to load, and there are two for the 
% lesions and prostate of the phantom and two for the lesion and prostate 
% for the patient data. This need to be separated into the different parts 
% if possible. 

% function call
disp('LoadMRIContourPoints has been called')

% add paths
addpath('../data/PatientPointData','../data/PhantomPointData');

% set myPoints to be length of input arguments
myPoints = nargin;

switch (nargin)
    % if no inputs then call open dialog box
    case 0
        % get the file and path with dialog box
        [fileName ,pathName ] = uigetfile;
        % load the points
        myPointsSort = load([pathName,fileName]);
        % call the sort me function
        myPoints = sortMe(myPointsSort,fileName);
        
    % with one input argument    
    case 1
        % try load the filenae given
        try
            % try loading that file
            fileName = varargin{1};
            myPointsSort = load(fileName);
        catch 
            % load display box if you cant load that file
            disp('File not recognised');
            % try open a UI
            try
            [fileName ,pathName ] = uigetfile;
            myPointsSort = load([pathName,fileName]);        
            catch me
                disp(me.message)
                myPoints.data = NaN;
                myPoints.name = 'Nope';
                return;
            end
        end
        
        % after points are loaded call sort me function
        myPoints = sortMe(myPointsSort,fileName);
    otherwise
        disp('Please only use one input argument')
end


end

function [myPoints] = sortMe(input,fileName)
%% This function sorts the data, by extracting the xy from the cells
% and adding to one matrix with a z coordinate. For every lesion. this
% function then calls the nested function, 'filterMe' which has been
% hard coded to filter the different parts of the prostate and lesions
% into seperate objects.

% as some have lesion or prostate points try both, to ensure it won't break
try
    % try load the lesion points
    slices = length(input.lesionPoints);
    input.Points = input.lesionPoints;
catch
    try
        % otherwise load prostate points
        slices = length(input.prostatePoints);
        input.Points = input.prostatePoints;
    end
end


% Set a temporary variable
temp = [0 , 0 ,0];

for idx = 1:slices;
    
    % Check state of cell
    state = isempty(input.Points{idx});
    
    % if state isnt empty
    if state == 0;
        for jdx = 1:length(input.Points{idx});
                      
            % Find the number of coordinates in that file
            coord = length(input.Points{idx}{jdx}(:,1));
            
            % add all the points into one n * 3 vector, columns [x y z]
            temp = [temp(:,1) , temp(:,2), temp(:,3);...
                input.Points{idx}{jdx}(:,1), ...
                input.Points{idx}{jdx}(:,2),...
                ones(coord,1)*idx];
        end
    end
    
    
end

% filter the points into seperate prostate/lesion parts
myPoints = filterMe(temp(2:end,:),fileName);

end

function [myPoints] = filterMe(input,fileName)
% this function seperates the points, so each lesion and prostate part can
% be processed seperately, the filename indicates which method to choose.
% this has been hardcoded for the data set provided.

% 
switch fileName
    % in the case of any patient data
    case {'PatientLesionMRContourPoints.mat','PatientProstateMRContourPoints.mat'}
        % If patient data lesions
        myPoints.data = input;
        myPoints.name = fileName(1:(end-4));
        % only one object to return for patient data, so doesnt need
        % sorting
        
    % in the case of any phantom data, for lesions
    case 'PhantomLesionMRContourPoints.mat'
        % if point data lesions for phantom
        disp(fileName)
        disp('case 3')
        
        % seperate z - x axis
        temp1 = []; temp2 = []; temp3= [];
        
        % using constraints to sort the data, for every data points
        for i = 1:length(input)
            % to seperate lesion 1
            if (input(i,1) < 60)
                temp1(size(temp1,1)+1,:) = input(i,:);
            % to seperate lesion 2
            elseif (input(i,1) > 60) && (input(i,3) > 25)
                temp2(size(temp2,1)+1,:) = input(i,:);
            % otherwise lesion 3
            else
                temp3(size(temp3,1)+1,:) = input(i,:);
            end
        end
        
        % assign the temporary variables to output structure
        myPoints(1).data = temp1;
        myPoints(2).data = temp2;
        myPoints(3).data = temp3;
        % assign name
        for idx = 1:3
            myPoints(idx).name = fileName(1:(end-4));
        end
        
    case 'PhantomMRContourPoints.mat'
        % if point data lesion for phantom
       
        disp(fileName)
        disp('case 4')
        
        % z-y plane - diagonal plane to split the field
        m = -0.46875;
        xlimit = 75;
        
        % initalise matrices
        temp1 = []; temp2 = []; temp3= [];
        
        for i = 1:length(input)
            if (input(i,3) > (m*(input(i,2)-102)+51)) && (input(i,1) > xlimit)
                % for first semicalvesicle
                temp3(size(temp3,1)+1,:) = input(i,:);
                
            elseif (input(i,3) > (m*(input(i,2)-102)+51)) && (input(i,1) < xlimit)
                % for second semicle vesicle
                temp2(size(temp2,1)+1,:) = input(i,:);
            else
                % for the rest of the prostate
                temp1(size(temp1,1)+1,:) = input(i,:);
            end
        end
        
        % assign temporary variables
        myPoints(1).data = temp1;
        myPoints(2).data = temp2;
        myPoints(3).data = temp3;
        % assign name
        for idx = 1:3
            myPoints(idx).name = fileName(1:(end-4));
        end
        
    otherwise
        % if new data/ not recognised path
        disp('Otherwise')
        myPoints.data = input;
        myPoints.name = 'Unknown';
end

end
