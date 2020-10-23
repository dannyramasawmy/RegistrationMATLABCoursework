function [ plotHandle ] = DisplayMRIwithContours(myImage,myPoints,slice,varargin)
    % Created February 2016
    % Student Number: 15102411
    %
    % INPUT:
    %   The inputs are a myImage object from LoadDICOMVolume, with the .volume
    %   attribute
    %   a myPoints object, from LoadMRIContourPoints
    %   and a slice number which must be an integer, and relate to one of the
    %   slices in the MRI volume.
    %
    % PROCESS:
    %   The function plots the image slice from the volume using imagesc
    %   then plots the overlaying contour points, it uses find, to find the
    %   right z coordinates of the slice.
    %
    % OUTPUT:
    %   The output is a handel to the figure, so the user can edit
    %   properties of the figure post calling the function.
    %
    % DESCRIPTION:
    %   This script is to test displaying an mri volume slice with mr contour
    %   points, the contour points must relate to the image. The overlayed
    %   points can be in different styles thicknessess and colours.
    
    % Check input argumetns
    switch (nargin-3)
        case 0
            % if no extra input arguments (default)
            try
                plotHandle = plotMe(myImage,myPoints,slice);
            catch me
                % catch case with bad inputs
                disp('Cannot Plot, wrong input arguments')
                plotHandle = 0;
            end
        otherwise
            % if varargin
            plotHandle = plotMe(myImage,myPoints,slice,varargin);
    end
    
    
end

function [plotHandle] = plotMe(myImage,myPoints,slice,varargin)
    
    try
        % try find the slice number in the volume
        temp = myImage.volume(:,:,slice);
    catch
        % if cannot find the slice then set slice to 1
        disp('Not a valid slice, Displaying slice 1')
        slice = 1;
        temp = myImage.volume(:,:,1);
    end
    
    % get a new figure handle
    myFig = figure;
    % open figure
    figure(myFig)
    
    % display image
    plotHandle = imagesc(temp);
    colormap bone;              % plotting niceties
    axis image xy;              % making the image nice
    %
    
    % plot contour
    % if multiple points in the structure
    try
        for idx = 1:length(myPoints);
            
            % reassign data for temporary variable
            tempData = myPoints(idx).data(:,:);
            
            % find indices where the slice is correct
            zidx = find(tempData(:,3) == slice);
            
            % if there is a valid slice
            if length(zidx) > 0
                
                % find the points
                points = tempData(zidx,1:2);
                
                % open current figure
                figure(myFig)
                hold on
                % plot points
                plotHand = plot([points(:,1);points(1,1)],...
                    [points(:,2);points(1,2)]);
                
                % Try plot the extra bits an bobs if given
                try;
                    % try plot the line widths
                    plotHand.LineWidth = varargin{1}{1}(idx);
                end
                try;
                    % try plot the colours
                    plotHand.Color = varargin{1}{2}(idx,:);
                end;
                try;
                    % try plot the line styles
                    plotHand.Marker = varargin{1}{3}(idx);
                end;
                
                
                hold off
                
            end
        end
        % if it cannot plot the contour points
    catch
        disp('Was not a fan of the contour points');
    end
    
    plotHandle = figure(myFig);
    
    % label things
    xlabel('x-axis [mm]')
    ylabel('y-axis [mm]')
    title([myImage.name,'Slice: ',num2str(slice)])
end









