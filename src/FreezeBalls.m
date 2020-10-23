function [myEllipsePoints] = FreezeBalls(myOptGrid,myUSImage,varargin)
    %% TestFreezeBall
    % Created February 2016 : edit March 2016
    % Student Number: 15102411e
    %
    % INPUT:
    %   The input is the myOptGrid object from FindOptimalGridCoords
    %   function, which carries information such as the grid point data,
    %   the three optimal grid points for the lesion, and the transposed
    %   lesion coordinates. The second input is the Ultrasound image, and
    %   there is an optional input argument for a 'Print' Flag to display a
    %   step by step through the US image with the gridpoints, optimal grid
    %   point, lesion data and cryotherapy data overlayed.
    %
    % PROCESS:
    %   The
    %
    %
    % OUTPUT:
    %   This outputs the optimal grid coordinates of release for the lesion
    %   and also the X Y Z data of the ellipse created. The output is a
    %   myEllipsePoints structure with fields:
    %           myEllipsePoints.releastPoint : [x y z] coordinate relating
    %           to the  X Y needle grid points and the Z depth
    %           myEllipsePoints.data         : the points describing the
    %           size and shape of the ellipse in [x y z] TRUS coordinates
    %
    % DESCRIPTION:
    %    This test script tests whether an ellipse with long-short axis of 0.6 can
    %    be constructed to surround the lesions. The script makes use of the all
    %    the previous functions, but especially the FindOptimalCoordinatees
    %    function which outputs a myOptGrid structure, which contains all the
    %    useful calculations from that function to be used to find the optimal
    %    release coordinates and size of the ice ball.
    
    gridPoints = myOptGrid.grid;
    roundMRT = [];
    freezer = [];
     
    for lesionNo = 1:length(myOptGrid)
        
        % Transposed lesion points
        MRTrans = myOptGrid(lesionNo).MRTransPoints ;
        % i and j voxel MR to US conversion
        sfa = myOptGrid(lesionNo).pixelConv(1);
        % z voxel MR to US conversion
        sz = myOptGrid(lesionNo).pixelConv(2);
        
        % find means of lesion coordinated
        lesMeans = mean([MRTrans(:,1:3)]);
        
        % Find the optimal release poitns
        myEllipsePoints(lesionNo).releasePoint = [myOptGrid(lesionNo).bestPoints(1,1),...
            myOptGrid(lesionNo).bestPoints(1,2),lesMeans(3)];
        
        % temp release points as needle release points are different from
        % the centre of the lesion
        rpnt = myEllipsePoints(lesionNo).releasePoint;
        
        % new eucledian distance from lesion contour points to needle centre
        RPT = repmat(rpnt,length(MRTrans),1);    
        eucDist = sqrt(sum( (MRTrans-RPT).^2 ,2));
        
        % sort the points, from smallest distance and take the first 3 coords
        sorted = sort(eucDist);
        
        % Ellipsoid radii add
        xz =  (sorted(1)+4); 
        yz = xz/0.6 /sfa ;
        zz = xz/0.6 /sfa;
        xz = xz*sz;
        
        % make my ellipse centered around grid coords
        [X,Y,Z] = ellipsoid(myOptGrid(lesionNo).bestPoints(1,1),...
            myOptGrid(lesionNo).bestPoints(1,2),lesMeans(3),zz,yz,xz,30);
        
        % collate the data
        myEllipsePoints(lesionNo).data = [X(:), Y(:),Z(:)];
        
        % points to plot
        roundMRT = [roundMRT ; MRTrans(:,1),MRTrans(:,2),round(MRTrans(:,3))];
      
        % get ablate points to plot
        freezer = [freezer ; myEllipsePoints(lesionNo).data(:,1:2),...
            round(myEllipsePoints(lesionNo).data(:,3))];
    end
    
    %% Varargin , should I plot or should I go?
    switch isempty(varargin)
        case 0
            switch varargin{1}
                case 'Print'
                    % open figures
                    fig1 = figure; fig2 = figure;
                    
                    % plot the 3D points
                    PlotMyThings2(myEllipsePoints,roundMRT,fig2);
                    
                    % plot figures
                    PlotMyThings(myUSImage,gridPoints,roundMRT,...
                        freezer,myOptGrid,fig1);
                    

            end
    end
    
end

function [figNo] = PlotMyThings(myUSImage,gridPoints,roundMRT,ablate,gps,figNo)
    %% This nested function DISPLAYS the slice of the US with the extra c
    % contours and the expected frozen region zone
    
    for i = 1:size(myUSImage.volume,3)
        figure(figNo)
        % Display the image
        imagesc(myUSImage.volume(:,:,i)), alpha(0.5)
        % color
        colormap bone
        % labels
        title(num2str(i))
        % plot other stuff on it
        hold on
        % plot the grid poitns
        plot(gridPoints(:,1),gridPoints(:,2),'r.')
        % highlight the grid points which are important for the operation
        
        % plot in a forloop
        for j = 1:3
            try
                if (i >= gps(j).SE(1)) && (i <= gps(j).SE(2))
                    
                    pltHand = plot(gps(j).bestPoints(1,1),gps(j).bestPoints(1,2),'sy');
                    pltHand.LineWidth = 1;
                end
            catch
            end
        end
        
        % plot the contour points over the slice and optimal poisiotns
        hold on
        idx = find(roundMRT(:,3)==i);
        plot(roundMRT(idx,1),roundMRT(idx,2),'b*')
        idx = find(ablate(:,3)==i);
        plot(ablate(idx,1),ablate(idx,2),'r*')
        
        % wait for user input
        drawnow; pause;
        hold off
        
    end
end

function [fig2] = PlotMyThings2(myEllipsePoints,roundMRT,fig2)
    %% This nested function plots the £D contour points for the lesions and
    % the expected frozen region
    
    
    % plot the 3D points in a loop
    for lesionNo = 1:length(myEllipsePoints);
            figure(fig2)
        hold on
        % plot the ellipse data
        plot3(myEllipsePoints(lesionNo).data(:,1),...
            myEllipsePoints(lesionNo).data(:,2),...
            myEllipsePoints(lesionNo).data(:,3),'b.')
    end
    
    figure(fig2)
    hold on
    plot3(roundMRT(:,1),roundMRT(:,2),roundMRT(:,3),'ro')
    
    % labels
    xlabel('x');ylabel('y');zlabel('z');
    
    % titles
    title('Lesion and Expected Frozen Region')
    
    % grid
    grid on
    
end
