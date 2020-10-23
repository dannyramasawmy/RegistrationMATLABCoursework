function [ plotHandle ] = DisplayMRIContourPointsIn3D(myPoints,varargin)
    % Created February 2016: edit March 2016
    % Student Number: 15102411
    %
    % INPUT:
    %     The input o the function is a myPoints object from the function
    %     LoadMRIContourPoints. This has attributes .data, which stores the
    %     [x y z] data for 3D plotting. Alternatively, since this is the only
    %     field that is used, any array could be assigned to a .data field and
    %     plotted here.It can have any number of extra input arguments,
    %     these will only be used if they are in the order of 1 by n
    %     dimensional vector of linewidths, a n by 3 array of colours, 1:3
    %     and a string of point styles.
    %
    % PROCESS:
    %     The function uses scatter 3 function to plot the points in a forloop,
    %     the forloop has the same number of loops as the length of the myPoints
    %     structure. by holding on and plotting in a loop it allows, each one to
    %     have the specific line style and, colours etc individually.
    %
    % OUTPUT:
    %     plotHandle, the figure handle, so each property can be edited
    %     after calling this function
    %
    % DESCRIPTION
    %     Want to plot 3D Data from previous functions
    
       
    % open figure
    myFig = figure;
    
    % see if there are additional input arguments or not
    switch (nargin-1)
        % no extra inputs
        case 0
            try
                % plot my data with different colours
                plotHandle = plotMyData(myPoints,myFig);
            catch me
                % if it cannot plot display message
                disp(me.message)
                close(figure(myFig))
            end
            
            % extra inputs
        otherwise
            try
                % plot my data with different colours
                plotHandle = plotMyData(myPoints,myFig,varargin);
            catch me
                % if it cannot plot display message
                disp(me.message)
                lose(figure(myFig))
            end
    end
    
end

function [plotHandle] = plotMyData(myPoints,myFig,varargin)
    % This function plots the data, it requires the myPoints
    % to be a contour point object from one of the first questions
    % it takes the handle to the figure, opened at the start
    % excepts extra arguments for line styles
    
    
    for i = 1:length(myPoints)
        
        %  open my figure again
        figure(myFig)
        % hold on
        hold on
        
        % plot the data x - y - z
        plotHandle = scatter3(myPoints(i).data(:,1),myPoints(i).data(:,2),...
            myPoints(i).data(:,3),'o');
        
        % turn warnings off
        warning off;
        
        %
        switch (nargin-2)
            % if extra inpt arguments
            case 0
            otherwise
                % try plot the line width
                try
                    % change line width
                    plotHandle.LineWidth = varargin{1}{1}(i);
                catch m
                    % display warning
                    warning(m.message);
                end
                % try plotting the color data
                try
                    % change color
                    plotHandle.CData = varargin{1}{2}(i,:);
                catch m
                    % display warning
                    warning(m.message);
                end
                % try plotting the marker style
                try
                    % change marker style
                    plotHandle.Marker = varargin{1}{3}(i);
                catch m
                    % display warning
                    warning(m.message);
                end
        end
        
        
        % remove hold
        hold off
    end
    
    % put a grid on
    grid on
    % label axes
    xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Z [mm]')
    % set view
    view([1,1,-1])
    % set axis
    % %     axis image
    
    % return the image axis
    plotHandle = figure(myFig);
end