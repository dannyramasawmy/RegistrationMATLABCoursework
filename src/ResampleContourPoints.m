function [ myNewPoints ] = ResampleContourPoints(myPoints,varargin)
%% ResampleContourPoints
% Created February 2016 : edit March 2016
% Student Number: 15102411
%
% INPUT:
%   The inputs to the function are a myPoints object from the function
%   LoadMRIContourPoints. or a sturcture with an attribute .data which
%   contains the [x y z] coordinates of the slices. The second input does
%   not need to be specified and is used if the user wants a specific
%   number of points back, otherwise the function returns approximately 100
%   points.
%
% PROCESS:
%   The function fits a circular spline using cscvn, to the points, the
%   first and last point has to be the same to close the circle. The
%   resampled points are then sampled again to get approximately 300
%   points. Then if there is a user defined number of returned points then
%   linspace is used to select evenly distrbuted number of points between
%   the starting and ending points. The defualt return number is 100
%   poitns.
%
% OUTPUT:
%   The output is an objects with the same data fields as myPoints input.if
%   the input myPoints is multidimensonal the outpur will also be multidimensional.
%   myNewPoints.data: [x y z] coordinates of all the poitns 
%   myNewPoints.name: The name of each of the points input
%   
%
% DESCRIPTION:
% This scripts tests the resample contour point function, by upsampling the
% points witha user defined input. It fits a circular spline to the ocntour
% points on the slices and can be resampled upto approximately 300 points.
% If the user wants more than 300 per slice then there are repeated points.
% 

for grp = 1:length(myPoints)
    % Find the maximum slice to interate through
    maxSlice = max(myPoints(grp).data(:,3));
    
    % initialsie first row of points
    myNewTempPoints(grp).data = [0,0,0];
    
    for zdx = 1:maxSlice
        
        % for each slice number find if there are indices relating to it
        index = find(myPoints(grp).data(:,3)==zdx);
        
        % if they arent empty
        switch isempty(index)
            case 0
                % assign a temporary variable for convenience
                temp = myPoints(grp).data(index,1:2);
                temp = [temp; temp(1,1) ,temp(1,2)];

                % fit a curve
                pp = cscvn(temp');
                t2 = fnplt(pp)';
                
                % resample fitted curve to get approx 300 points
                pp2 = cscvn(t2');
                bb = fnplt(pp2)';
                
                % if extra input
                switch isempty(varargin)
                    case 0
                        % round incase they try to break it
                        input = round(double(varargin{1}));
                        
                    otherwise
                        input = 100;
                end
                
                % just incase the user has a vector input
                input = input(1);
                
                % under sample points
                noPoints = round(linspace(1,length(bb(:,1)),input));
                a = bb(noPoints,:);
                
                % Add the new points to a new structure, including old ones
                myNewTempPoints(grp).data = [myNewTempPoints(grp).data(:,1),...
                    myNewTempPoints(grp).data(:,2),...
                    myNewTempPoints(grp).data(:,3);...
                    a(:,1),a(:,2),ones(length(a(:,1)),1)*zdx];
        end
    end
    
    % assign new point data
    myNewPoints(grp).data = myNewTempPoints(grp).data(2:end,:);
    % return the names
    try
        myNewPoints(grp).name = [myPoints(grp).name,'-Resampled'];
    catch
        % just incase the .name field doesnt exist
        myNewPoints(grp).name = 'Not Available';
    end
end

end

