function [myImage] = LoadDICOMVolume(varargin)
%
% INPUTS :
%   The inputs can be any number of the four specific image cases to load,
%   an integer number from 1 to 4, which corresponds to the related images, or 
%   have no input arguments. Any input arguments not recognised will cause the
%   function to return a structure with all the images loaded.
%         
% PROCESS : The function has a nested function, called 'loadMe', which takes an
%     input argument of an integer which refers to one of the image folders.
%     It reads all the files in the directory and loads them with, 
%     'dicomread'. The main function sorts the input arguments of varargin.
%     multiple input arguments calls the function again for each argument.
%    
% OUTPUTS
% LoadDICOM returns an object in a structure called 'myImage' which has attributes
%     .dimensions:    the dimensions of the pixels [x y z]
%     .volume:        the image volume of the DICOM slices [112 112 50]
%     .dimStr:        a string of the dimensions scale of the dimension 'mm'   
%     .name:          the name of the loaded file , 'MRI-Phantom' 
%     .info:          the DICOM info structure, for extra information
%     .SliceSpacing:  the inter slice spacing of the slices

% DESCRIPTION
%     For computing foundations MATLAB 2015/2016 coursework, this test function
%     loads images in the DICOM format. The images must be places in the specified
%     search paths. ie ../data/ . However the function this test script calls
%     has been limited to only allow folders on specific paths for two reasons. The
%     first reason means that only the two MRI and two TRUS DICOM image volumes 
%     specific for this task can be loaded, secondly to allow a quicker method for
%     calling the specific volumes by providing an integer value. This can be 
%     seen in the test script below.
% 
% RELEVANT FUNCTIONS
% LoadDICOMVolume
%
%
%
disp('LoadDICOMVolume has been called.')

%% Check Paths
addpath(genpath('../data'),'../src','../files/');

%% Sort Input Arguments
% sort the input argumetns then call load me function

switch nargin
    % Case when no input arguments
    case 0
        % Return all the output arguments if no inputs
        disp('No input arguments returning everything')
        myImage = loadMe(1:4);
    % Case with one input argument
    case 1
%         disp('1 input argument')
        switch varargin{1}
            case {0}
                % for a zero give back all the data
                myImage = loadMe(1:4);
            case {1,2,3,4}
                % for a integer 1:4 return one of the data - in order of
                % below
                myImage = loadMe(varargin{1});
            case {'MRI-Anon'}
                % load patient data
                myImage = loadMe(1);
            case {'MRI-Phantom'}
                 % load phantom data
                myImage = loadMe(2);
            case {'TRUS-Anon'}
                % load ultrasound patient data
                myImage = loadMe(3);
            case {'TRUS-Phantom'}
                % load ultrasound phantom data
                myImage = loadMe(4);
            otherwise
                % cannot find a suitable case
                disp('Not a valid input option')
                myImage = loadMe(1:4);
        end
    % case with multiple input arguments    
    otherwise
        % Recursively call function for each single input
%         disp('Multiple input arguments, returning as structure')
        for idx = 1:nargin;
            myImage(idx) = LoadDICOMVolume(varargin{idx});
        end
        
end

end


function [myImage] = loadMe(input)

% Names of the images
names = {'MRI-Anon','MRI-Phantom','TRUS-Anon','TRUS-Phantom'};

% set a counter for indexing to 0
counter = 0;

% for loop can do single or multiple entries
for i = input
    
   
    % string to get to the right directory (../data)
    str{i} = ['../data/',names{i}];
    
    % increment counter
    counter =counter + 1;
    
    % create  a list of the directory by that name in the data
    listsTemp = dir(str{i});
    
    % This checks for files which may not be dcm
    for idx = 3:length(listsTemp)
        if ((listsTemp(idx).name((end-2):end)) == 'dcm')
            lists(idx) = listsTemp(idx);
        end
    end
    
    % loop over the list to load data into a structure
    % first two arguments of dir are useless
    for j=3:(length(lists))
        % read slices and assign to a volume
        myImage(counter).volume(:,:,(j-2)) =  dicomread(lists(j).name);
    end
    
    % other parts of information
    % read the name slices
    info = dicominfo(lists(j).name);
    % find the dimensions of the slice voxels
    myImage(counter).dimensions = [info.PixelSpacing',...
        info.SliceThickness];
    % assign a measurment scale
    myImage(counter).dimStr = 'milimeters';
    % assign a name
    myImage(counter).name = names{i};
    % assign the DICOM-info
    myImage(counter).info = info;
    
    % if there is an interslice spacing
    try
        myImage(counter).SliceSpacing = info.SpacingBetweenSlices;
    catch me
        myImage(counter).SliceSpacing = 0;
    end
    % clear temporary variable incase of for-loop
    clear lists
end

end
