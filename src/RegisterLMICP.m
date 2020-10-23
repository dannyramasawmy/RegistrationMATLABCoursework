function [ myICPData] = RegisterLMICP(myMasks,myPoints,varargin)
    % RegisterLMICP
    % Created February 2016 : edit March 2015
    % Student Number: 15102411
    %
    % INPUT:
    %   The input to this function is the myMasks objects, and myPoints to
    %   registed. The extra input arguments are used if the user wants to
    %   print the results of the function automatically. These addinitonal
    %   print functions are included as nested functions.
    %
    % PROCESS:
    %   The function has lots of nested functions, the aim to create an
    %   objective function which is minimised when the transformation
    %   matrix*the incoming points TP  is equal to or close to equal to the
    %   closest corresponding points on the mask surface given by Q. it
    %   uses lsqnonlin to minimise the Transformation matrix which is a
    %   function of the phi vector - three angles and a transform
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
    %       myICPData.type  : the agorithm type 'Levenberg Marquardt'
    %
    % DESCRIPTION:
    %   This test script checks if the ICP algrothim converges, and sees the
    %   results of the starting and ending points of the algorith. It does this
    %   for the MRI points to MRI surface and the US Points to the MRI surface
    %   from myMasks
    
    % Give it the mask
    imMask = myMasks.volume;
    
    
    % Generate points and perturbations
    points = genPoints(myPoints);
    
    % Find the Shell
    imMaskPerim = ShellMask(imMask);
    
    % find the index
    [~,index] = bwdist(imMaskPerim);
    
    %% Set up initial points
    
    % angles
    alpha = 0;      % rotation about anti-c x
    beta = 0;       % rotation about anti-c Y
    gamma = 0;      % rotation about anti-c Z
    t1 = 0;
    t2 = 0;
    t3 = 0;
    
    % Vec to min
    phi = [alpha,beta,gamma,t1,t2,t3];
    
    %% Find Q and P
    P = points';
%     Q = correspondingQvector(points,index,imMask);
    
    % Creat function handle to the objective Function
    objFun = @(phi) objectiveFunction(phi,P,index,imMask);
    
    % set options
    opt = optimoptions('lsqnonlin','Algorithm','levenberg-marquardt');
    % options.MaxFunEvals
    
    % lsqnonlin to find minimum parameters
    [x,~,~,~,~] = lsqnonlin(@(phi) objFun(phi),...
        phi,[],[],opt);
    
    % Find the transformation matrix
    solvedT = findTransform(x);
    
    % Transform point, find final P and Q vector
    outP    = (solvedT*points')';
    lastQ   = correspondingQvector(outP,index,imMask)';
    outP = outP(:,1:3); lastQ = lastQ(:,1:3);
    
    % Calculate SSD, TRE, RMS and DCE
    SSD     = sum(sum(((outP-lastQ).^2)));
    TRE     = norm((mean(outP)-mean(lastQ))); % not correct, can be reassigned
    RMS     = sqrt(SSD/length(outP));
    DSC     = 0;
    
    %% Outputs
    myICPData.T     = solvedT;
    myICPData.RMS   = RMS;
    myICPData.TRE   = TRE;
    myICPData.DSC   = DSC;
    myICPData.SSD   = SSD;
    myICPData.data = outP(:,1:3);
    myICPData.type  = 'Levenberg Marquardt Algorithm';
    
    
    %% Sort Varargin is print then print figures
    switch (nargin-2)
        case 0
            % no extra argument ignore printing
            disp('Will not print');
        otherwise
            % some other arguments so will print the figures
            disp('Figures Will be printed');
            figNo = figure;
            plotMyReg(figNo,imMask,points,outP);
    end
    
end

function [points] = genPoints(myPoints)
    %% Can be altered to perturb starting points / concatenates starting
    % points if my Points is long
    
   
        % concatenate
    points = vertcat(myPoints.data);
    
    % comment this section out if just want to compound points
    % Add a column of ones
    points = [points , ones(length(points),1) ]';
    
    % Define a point peturbation
    T =   [ 1       0       0       0 ;
            0       1       0       0 ;
            0       0       1       0 ;
            0       0       0       1 ];
    
    % transform points
    pt = T*points;
    
    % Return Points
    points = pt(1:4,:)';
    
    % uncomment to under sample points
    % points = points(round(linspace(1,length(points),100)),:);
    
    % uncomment to add normally distributed noise to points
%     points = points + 5* randn;
    
end

function [imMaskPerim] = ShellMask(imMask)
    %% Yhis function shells the mask for imMask
    % Create a perimiter of the mask
    
    % Loop over the Z - direction
    for i = 1:size(imMask,3);
        % take the perimiter
        imMaskPerim(:,:,i) = bwperim(imMask(:,:,i));
    end
    
end

function [minVec] = objectiveFunction(phi,P,index,imMask)
    % This function is the objective function for lsqnonlin to be
    % minamised, it is a minimum when, Q = TP, the corresponding points is
    % equal to the Transform mulitplied by the orgiional points
    
    % Find T*P
    TP = (findTransform(phi)*P)';
    
    % Update the Q vector
    Q = correspondingQvector(TP,index,imMask)';
    
    % minimisation vector
    minVec = sqrt( (sum((TP-Q).^2,2)) );
end

function [Qvec] = correspondingQvector(points,index,imMask)
    % Finds the corresponding Q vector
    
    % Round the input points
    roundedp = round(points(:,1:3));
    
    % sort out the indexs if less than 1
    roundedp(find(roundedp(:,1)<1),1)   =   1;
    roundedp(find(roundedp(:,2)<1),2)   =   1;
    roundedp(find(roundedp(:,3)<1),3)   =   1;
    
    % sort out peaking indices
    roundedp(find(roundedp(:,1)> size(imMask,2)),1) =   size(imMask,2);
    roundedp(find(roundedp(:,2)> size(imMask,1)),2) =   size(imMask,1);
    roundedp(find(roundedp(:,3)> size(imMask,3)),3) =   size(imMask,3);
    
    %             initalise
    newPoints = zeros(length(roundedp),3);
    
    % over the length of the vector
    for i = 1: length(roundedp);
        
        try
            % find the index
            [a , b , c] = ind2sub(size(imMask),index(roundedp(i,2),...
                roundedp(i,1),roundedp(i,3)));
            
            % new points
            newPoints(i,1) = b; newPoints(i,2) = a; newPoints(i,3) = c;
            
        catch me
            % Display the error message
            disp(me.message)
        end
    end
    
    % the new Q vector
    Qvec = [newPoints,ones(length(roundedp),1)]';
    
end

function [T] = findTransform(phi)
    
    % assign rotations and translations
    alpha   = phi(1);
    beta    = phi(2);
    gamma   = phi(3);
    t1      = phi(4);
    t2      = phi(5);
    t3      = phi(6);
    
    % R matrix
    % alpha rotation matrix
    alphaMat = [1,  0,  0                   ;
        0,  cos(alpha),  sin(alpha) ;
        0,  -sin(alpha), cos(alpha)];
    
    % beta rotation matrix
    betaMat = [cos(beta),   0,   -sin(beta) ;
        0,           1,    0         ;
        sin(beta),   0,  cos(beta)  ];
    
    % gamma rotation matrix
    gammaMat = [cos(gamma)  , sin(gamma),   0;
        -sin(gamma) , cos(gamma),   0;
        0           , 0         ,   1];
    % Rmatrix
    R = gammaMat * betaMat * alphaMat;
    
    % translation vector
    t = [t1 t2 t3]';
    
    % T matrix
    T = [R          , t ;
        zeros(1,3)  , 1];
    
end

function [] = plotMyReg(figNo,imMask,points,transP)
    
    % open figure
    figure(figNo);
    
    % surface from mask
    isosurface(imMask);
    
    hold on
    
    % plot starting points
    plot3(points(:,1),points(:,2),points(:,3),'k.')
    
    % Plot ending poitns
    plot3(transP(:,1),transP(:,2),transP(:,3),'r*')
    
    % legend
    legend('Surface','Starting','Ending')
    
    % labels
    xlabel('X-axis')
    ylabel('Y-axis')
    zlabel('Z-axis')
    title('Before and After Registration to Surface')
end