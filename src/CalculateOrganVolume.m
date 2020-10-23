function [ myVolume ] = CalculateOrganVolume(myInput,varargin )
% CalculateOrganVolume
%
% Created February 2016
% Student Number: 15102411
%
% INPUT:
%   myInput can either be the contour points or the mask, if the mask is
%   given then the dimensions for the voxel are already given. If the input
%   are the contour points, then the dimension of the voxels neeed to be
%   given.
%
% PROCESS:
%   The contour points can be calculated using the trapezium rule, this has 
%   been done using a nested function instead of the inbuilt MATLAB
%   function, by recognising that the points are already in order from
%   resampling. The trapezium rule can be vectorised by taking away the
%   first poitns from the next points, then finding the average in y and
%   summing them. In the case where the contour points need to be a
%   negative area, as it is a circle these are dealt with since the points
%   are already sorted. This then gives a per-slice nondimensional area and
%   need to be multiplied by the voxel dimensions which are given with
%   varargin. The summing can be done using 'sum' then multiplying by the
%   voxel dimensions which are wiht the mask. This function handles
%   multidimensional myMask objects and multidimenisional myPoitns objects
%   and can return the individual or total sum.
%
% OUTPUT: 
%   The output is a single or multiple vector of the volumes
%
% DESCRIPTION:
%   The objects have been made into isotropic masks from before, now the
%   aim is to estimate the organ volume from each. This can be done
%   directly from the contour points or can be got from summing the mask
%   and multiplying by the voxel volume


% See what kind of input it has
switch isempty(varargin)
    case 1
        try
            % for a structure input
            for object = 1:length(myInput)
                
                % Sum the elements in the vector
                voxelVolume = prod(myInput(object).dimensions(:));
                totalSum = sum(myInput(object).volume(:));
                
                % Total volume
                myVolume(object) = totalSum*voxelVolume;
            end
        catch me
            disp('Cannot compute volume, check input arguments')
            myVolume = NaN;
        end
        
    case 0
        % if varagin as something innit
        try
            % Try trapezium rule
            myNonDimVol = trapezium(myInput);
            
            % find volume
            myVolume = myNonDimVol*prod(varargin{1});
            
            % if an argument in varagin 2 then sum
            try
                switch isempty(varargin{2})
                    case 0
                        myVolume = sum(myVolume(:));
                end
            catch
                % if no argument in varargin 2 then dont worry about it
                disp('Returning a vector of volumes')
            end
                
            % if this doest work then display an error message
        catch me
            disp('Cannot computer volume, check input arguments')
            myVolume = NaN;
        end
end
end

function [myVolume] = trapezium(myPoints);
% Own trapz implementation

myVolume = zeros(1,length(myPoints));

for object = 1:length(myPoints)
    % find slice numbers
    lastSlice = max(myPoints(object).data(:,3));
    
    % intitalise slice vector
    totalSlice = zeros(1,lastSlice);
    
    for slice = 1:lastSlice;
        
        % find indexs
        index = find(myPoints(object).data(:,3)== slice);
        
        % temp vector
        temp = myPoints(object).data(index,1:2);
        
        % find xs and y s
        xs = temp(2:end,1) - temp(1:(end-1),1);
        ys = 0.5*(temp(2:end,2) + temp(1:(end-1),2));
        
        % sum of slice
        sumVec = xs.*ys;
        totalSlice(slice) = abs(sum(sumVec(:)));
    end
    
    % sum my volume
    myVolume(object) = sum(totalSlice(:));
end

myVolume;% = sum(myVolume(:));
end




