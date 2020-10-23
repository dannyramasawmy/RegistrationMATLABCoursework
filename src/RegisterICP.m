function [myICPData] = RegisterICP(myMasks,myPoints,varargin)
    % RegisterICP
    %  Created February 2016 : March 2015
    % Student Number: 15102411
    % INPUTS
    % myMask must be the sum of the masks
    %
    % INPUT:
    %   The input to this function is the myMasks objects, and myPoints to
    %   registed. The extra input arguments are used if the user wants to
    %   print the results of the function automatically. These addinitonal
    %   print functions are included as nested functions.
    %
    % PROCESS:
    %   This function uses the procrustes algrotihm whcih is listed in the
    %   coursework sheet, and will not be explained. (the p and q have been
    %   swapped to make it work). Ind2sub indices have to be reversed for i
    %   and j, because of the way matlab indexs the matrices.
    %
    %
    % OUTPUT:
    %   The output to this function is myICPData object which has
    %   attributes:
    %       myICPData.T     : The 4 by 4 transformation matrix
    %       myICPData.RMS   : The root-mean squared between the points and
    %                               the data
    %       myICPData.TRE   : The tracking error between the centre points
    %       myICPData.DSC   : an empty field than the DSC can be assigned
    %       myICPData.SSD   : the sum of squared differences between the
    %                           registered poitns and the surface
    %       myICPData.data  : the [x y z] data of the registered points
    %       myICPData.type  : the agorithm type 'Prscrustes-Algorithm'
    %
    % DESCRIPTION:
    %   This test script checks if the ICP algrothim converges, and sees the
    %   results of the starting and ending points of the algorith. It does this
    %   for the MRI points to MRI surface and the US Points to the MRI surface
    %   from myMasks
    %
    %
    
    %% IF Varargin is print then print figures
    switch (nargin-2)
        case 0
            % no extra argument ignore printing
            disp('Will not print');
            yesPrint = 0;
        otherwise
            % some other arguments so will print the figures
            disp('Figures Will be printed');
            yesPrint = 1;
            % Open Figures
            myFig1 = figure; myFig2 = figure; myFig3 = figure;
    end
    

    

    
    %% Return Masks and shell them
    imMask = myMasks.volume;
    
    % Shell my image Mask
    imMaskPerim = ShellMask(imMask);
    
    %% Concatenate points
    
    points = GenPoints(myPoints);
    
    % find centres
%     centre =abs(size(myMasks.volume)/2 - mean(points));
    
    % centre the points
%     points =points -  repmat(centre,length(points),1);
    
    %% Set Starting Parameters and initalise
    % Set origional points
    qOrig = points;
    
    % Set maximum SSD
    ssdBest = 1*10^20;      % To ensure the first SSD is better
    
    % maximum iterations
    iterTotal = 100;
    
    % Store all the T matrices
    Tstore = zeros(4,4,iterTotal);
    
    % calculate the minimum distances
    [~,index] = bwdist(imMaskPerim);
    
    
    %% Iterative loop
    for loop = 1:iterTotal
        disp(['Loop : ',num2str(loop)])
        % Round points tp be integers
        roundedp = round(points);
        
        % sort out the indexs if less than 1
        roundedp(find(roundedp(:,1)<1),1)   =   1;
        roundedp(find(roundedp(:,2)<1),2)   =   1;
        roundedp(find(roundedp(:,3)<1),3)   =   1;
        
        % sort out peaking indices
        roundedp(find(roundedp(:,1)>148),1) =   size(imMask,2);
        roundedp(find(roundedp(:,2)>122),2) =   size(imMask,1);
        roundedp(find(roundedp(:,3)>105),3) =   size(imMask,3);
        
        % initalise
        surfPnt = zeros(length(points),3);
        
        % for all the points find the corresponding close indices
        for i = 1: length(points)
            
            try
                % index a b c, find the linear index corresponding to 3 dim
                [a , b , c] = ind2sub(size(imMask),index(roundedp(i,2),...
                    roundedp(i,1),roundedp(i,3)));
                
                % closest surface points
                surfPnt(i,1) = b; surfPnt(i,2) = a; surfPnt(i,3) = c;
                
            catch me
                % just incase index out of bounds
                disp(me.message)
            end
        end
        
        
        %% assign P and Q, P and Q are flipped round
        P = surfPnt;            % points on the surface
        Q = points;             % the from the controu/ resampled points
        
        % Take the mean away from both, so centres are on 0
        Pbar = [P(:,1)-mean(P(:,1)) ,P(:,2)-mean(P(:,2)),P(:,3)-mean(P(:,3))];
        Qbar = [Q(:,1)-mean(Q(:,1)) ,Q(:,2)-mean(Q(:,2)),Q(:,3)-mean(Q(:,3))];
        
        
        % single value decomposition
        [U, ~, V] = svd(Q'*P);
        
        % rotation matrix
        R = V * [1  ,0  ,0 ;
            0  ,1  ,0 ;
            0  ,0  ,det(V*U') ] * U';
        
        % translation vector
        t = mean(P)' - R*(mean(Q))';
        
        % Transformation matrix
        T = [ R , t ;
            0 0 0 1];
        
        % Store T's
        Tstore(1:4,1:4,loop) = T;
        
        % with means
        Qt2 = [Q , ones(length(P),1) ]';
        
        % Transform old points
        Q2 = T*Qt2;
        Qupdate = Q2(1:3,:)';
        
        % calculate the sum of squared distances between surface and points
        ssd = sum(sum(((P-Qupdate).^2)));
        
        % Find the best SSD, just incase it creeps up
        if ssdBest > ssd
            minSSD = Qupdate;
            ssdBest = ssd;
            optimal = loop;
        end
        
        % Update points
        points = Qupdate;
        
        %% Compound Plotting throughout loops
        switch yesPrint
            case 1
                figure(myFig2)
                
                % mask Surface
                isosurface(imMask)
                hold on, plot3(Qupdate(:,1),Qupdate(:,2),Qupdate(:,3),'.'), hold off
                % Label Axis
                xlabel('X axis'), ylabel('Y axis'), zlabel('Z axis')
                title('Points Changing Over Iteration')
        end
    end
    
    %% Plotting
    switch yesPrint
        case 1
            % Plot origional
            PlotMyMasks(myFig1,imMask,imMaskPerim,points)
            
            % Plot the last mask
            PlotMyReg(myFig3,imMask,qOrig,Qupdate,minSSD)
    end
    
    %% Calculate Parameters
    RMS = sqrt(ssd/length(P));
    TRE = norm((mean(P)-mean(Qupdate)));
    DCE = 0; % Need to finished
    Tend = cumMultTransform(Tstore,optimal);
    
    %% OUTPUTS
    myICPData.T     = Tend;
    myICPData.RMS   = RMS;
    myICPData.TRE   = TRE;
    myICPData.DSC   = DCE;
    myICPData.SSD   = ssdBest;
    myICPData.data  = points;
    myICPData.type  = 'Proscrustes Algorithm';
end

function [imMaskPerim] = ShellMask(imMask)
    %% Yhis function shells the mask for imMask
    % Create a perimiter of the mask
    
    % initalise
    imMaskPerim = zeros(size(imMask));
    
    % Loop over the Z - direction
    for i = 1:size(imMask,3)
        imMaskPerim(:,:,i) = bwperim(imMask(:,:,i));
    end
    
end

function [points] = GenPoints(myPoints)
    %% Can be altered to perturb starting points / concatenates starting
    % points if my Points is long
    
    % stack points data - concatenate
    points = vertcat(myPoints.data);
    
    % comment this section out if just want to cconcat points =============
    % Add a column of ones
    points = [points , ones(length(points),1) ]';
    
    % Define a point peturbation change from Identity to peturb
    T =   [ 1       0       0       0 ;
            0       1       0       0 ;
            0       0       1       0 ;
            0       0       0       1 ];
    
    % transform points
    pt = T*points;
    
    % Return Points
    points = pt(1:3,:)';
    
    % uncomment to undersample
%     points = points(round(linspace(1,length(points),30)),:);
    
    % uncomment to add noise
%     points = points + 5*randn;
    
end

function [T] = cumMultTransform(Tmat,optimal)
    
    % incase the legnth is too long
    if optimal > size(Tmat,3);
        optimal = size(Tmat,3);
    end
    
    % intialise identity matrix to start
    temp= eye(4);
    
    % loop over every transform matrix
    for i = optimal:-1:1;
        % multiply with last step
        temp = temp*Tmat(:,:,i);
    end
    T = temp;
end

%% Plotting Functions, for code clarity

function [] = PlotMyReg(myFigNo,imMask,Qorig,Qup2,minSSD)
    %% Plot the Final image
    
    figure(myFigNo)
    
    % Plot Mask surface
    isosurface(imMask)
    
    hold on
    
    % Plot Origional Points
    plot3(Qorig(:,1),Qorig(:,2),Qorig(:,3),'r.')
    % Plot the Last Points
    plot3(Qup2(:,1),Qup2(:,2),Qup2(:,3),'ys')
    % Plot the Points with the lowest SSD
    plot3(minSSD(:,1),minSSD(:,2),minSSD(:,3),'*')
    
    hold off
    
    % Title
    title('Plot of Starting and ending Registration')
    
    % Legend
    legend('Surface Mask','Starting Points',...
        ' Last Points from algo', 'Lowest SSD');
    
    % Label Axis
    xlabel('X axis')
    ylabel('Y axis')
    zlabel('Z axis')
    
end

function [] = PlotMyMasks(myFigNo,imMask,imMaskPerim,points)
    %% Plots the image mask, the perimeter of the mask
    % ...and the inital poitns
    
    % names
    names = {'Origional Mask and Starting Points',...
        'Shell and Starting Points'};
    
    masks = {imMask,imMaskPerim};
    
    % open Figure
    figure(myFigNo)
    
    % first plot
    for i = 2:2
        
        % Choose Plot
        %     subplot(1,2,i)
        
        % surface of the Mask
        isosurface(masks{i})
        
        hold on
        
        % Points to Plot
        plot3(points(:,1),points(:,2),points(:,3),'ro')
        
        % Labels
        title(names{i})
        xlabel('X axis')
        ylabel('Y axis')
        zlabel('Z axis')
        
        hold off
    end
    
end

