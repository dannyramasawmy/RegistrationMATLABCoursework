function [ myMask ] =VoxelizeContours(myPoints,myImage,varargin)
% VoxelizeContours
% Created February 2016
% Student Number: 15102411
%
% INPUTS:
%   The inputs to the function are a myPoints object with fields .data and
%   .name and a myImage these are returned from LoadMRIContourPoitns and
%   LoadDICOMVolume. The extra input argument can be anything. This
%   function can process the myPoints object seperately, and returns the
%   number of masks equal to the number of dimensions of the myPoints
%   structure. If there is an extra input argument, 'Sum' then these masks
%   are combined.
%
% PROCESS:
%   This function uses the contour points and poly to mask to binarise the
%   image volume. It can process multidimensional myPoints objects looping
%   over every dimension. Therefor e can do each lesion and semi-vesicle
%   and prostate and return a 6 seperate masks for each. Alternatively if
%   varagin is NOT empty, the individual masks are summed. Processing the
%   poly2mask seperately reduces the rist that contour points are not
%   closed and seperate parts are joined accidentally.
%
% OUTPUT:
%   The output is a single or multi dimensional structure: with attributes
%       myMask.volume : an volume the same dimensions as myImage of a
%                           binary mask
%       myMask.dimensions :  the [x y z] voxel dimensions, to carry forward
%       myMask.sliceSpacing:    the inter slice spacing
%
% DESCRIPTION
%   Voxelize contours, converts the resampled points into a binary image,
%   this is done using the poly to mask function. The reasmpled points come
%   from the ResampleContourPoints function, which returns an object like
%   myPoints with fields.data and .name.
%

%% loop over every dimension in the myPoints bject, ie each lesions
for cluster = 1:length(myPoints);
    % loop for every slice
    for slices = 1:size(myImage.volume,3)
        % find the points which fall on this slice
        ind = find(myPoints(cluster).data(:,3) == slices);
        
        % make a temporary variable of these  points on the slice
        temp = myPoints(cluster).data(ind,:);
        
        % make two temporary vectore
        x = temp(:,1); y = temp(:,2);
        
        % imcomplement image then use poly to mask to binarise the poitns
        imp(cluster).im(:,:,slices) = imcomplement(...
            poly2mask(x,y,size(myImage.volume,1),size(myImage.volume,2)));
    end % end loop over every slice
end

%% check if there is an additional input argument
switch isempty(varargin)
    % if it is empty
    case 1
        % return a structure of the sime dimensions as the input myPoints
        for slices = 1:length(imp); 
            % the binary volume
            myMask(slices).volume = double(imcomplement(imp(slices).im));
            % take the dimensions from the myImage
            myMask(slices).dimensions = myImage.dimensions;
            % carry the slice spacing forward
            myMask(slices).SliceSpacing = myImage.SliceSpacing;
        end
        
    case 0
        % sum all the volumes together if varagin is NOT empty
        tmp = 0;
        % add the independent masks together
        for slices = 1:length(imp);
            tmp = tmp + imcomplement(imp(slices).im);
        end
        % the combined volume
        myMask.volume = tmp;
        % the dimensions
        myMask.dimensions = myImage.dimensions;
        % the inter slice spacign
        myMask.SliceSpacing = myImage.SliceSpacing;
end

end

