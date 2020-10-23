function [myOptGrid,fig1] = FindOptimalGridCoords(myMRPoints,myICPData,gridPoints,myUSImage,varargin)
    %%  Created February 2016 : edit March 2016
    % Student Number: 15102411
    % INPUTS:
    %   myMRPoints - a myPoints the lesion contour points of the MRI
    %    myICPData - a myICPData object from the data from the ICP functions
    %   gridPoints - the grid points from the coursework over the  US
    %    myUSImage - a myImage object from the previous functions
    %   varagin - can be set to 'Print' to return the step through display
    %
    % PROCESS:
    %   This function finds the optimal three grid points for the
    %   ultrasound abation of lesions within the prostate. It maximises the
    %   core cancel length by finding the closest distances to the centre
    %   points of each lesion. This assumes the lesions are symmetrical.
    %   The printing nested function allows the user to have a slice by
    %   slice step through guide with the lesions highlighted, the best
    %   three grid coords for each lesion. This function can handle
    %   multiple lesions if the lesions are a multidimensional myPoints
    %   object.IT returns a multidimensional structure with the three best
    %   coords for each.
    % 
    % OUTPUT:
    %   The function has two outputs, the second is a handle to the figure.
    %   The first is a myOptGrid object with attributes:
    %       myOptGrid.bestPoints : the three best x-y grid-coords for each
    %                                   lesion
    %       myOptGrid.SE         :  The starting and ending slices of 
    %                                   each of the lesions           
    %       myOptGrid.needleStartEnd : the recommended starting and ending
    %                                   points of the lesion after the 25 mm
    %                                    from the first point on the prostate. 
    %       myOptGrid.grid           : the grid point needle coordinates
    %       myOptGrid.MRPoints       : MR Lesion points
    %       myOptGrid.MRTransPoints  : Transformed lesion points
    %       myOptGrid.pixelConv      : [ij z] scaling for pixels 
    %
    % DESCRIPTION
    % This script registers the US points for the Patient and the Phantom to
    % the surface of the MRI, it also displays the USimage, with the optimal
    % hole positions step by step, with the contour points overlayed.
    %
    %
    roundMRT = [];
    
    for lesionNo = 1:length(myMRPoints)
        
        % find transformed poitns
        % temporary variable
        tmp = [myMRPoints(lesionNo).data];
        % transform points to US plane
        MRTrans = (inv(myICPData.T)*[tmp,ones(length(tmp),1)]')';
        
        % scale points back to US coordinate system
        switch myUSImage.name
            case 'TRUS-Phantom'
                MRTrans = [MRTrans(:,1)*2,MRTrans(:,2)*2,MRTrans(:,3)];
                sfa = 1/2;
                sz = 1;
            case 'TRUS-Anon'
                % only for patient data
                sfa = 0.1613/0.3609;
                sz = 1.9579/3;
                MRTrans = [(MRTrans(:,1)-100)/sfa,(MRTrans(:,2)-200)/sfa,MRTrans(:,3)/sz];
        end
        
        
        % find the mean of the X-Y coordinates
        MRT2 = repmat(mean([MRTrans(:,1:2)]),length(gridPoints),1); % With rounded 3rd dimension
        
        % calculate the euclidean distance from every point
        eucDist = sqrt(sum( (gridPoints-MRT2).^2 ,2));
        
        % sort the points, from smallest distance and take the first 3 coords
        [~,inds] = sort(eucDist);
        
        % assign best points into a structure
        myOptGrid(lesionNo).bestPoints = gridPoints(inds(1:3),:);
       
        % gps(lesionNo).SE = [tmp(1,3), tmp(end,3)];
        myOptGrid(lesionNo).SE = [min(round(MRTrans(:,3))), max(round(MRTrans(:,3)))];
        
        % add 25 to the start end points from known
        myOptGrid(lesionNo).needleStartEnd =myOptGrid(lesionNo).SE ...
            +(25-(min(myICPData.data(:,3))));
        
        % return gid coords
        myOptGrid(lesionNo).grid = gridPoints;
        
        % Send MR Points
        myOptGrid(lesionNo).MRPoints = myMRPoints(lesionNo).data;
        
        % Send MR Transposed points 
        myOptGrid(lesionNo).MRTransPoints = MRTrans;
        
        % sf sz
        myOptGrid(lesionNo).pixelConv = [sfa sz];
   
        % for plotting
        roundMRT = [roundMRT ; MRTrans(:,1),MRTrans(:,2),round(MRTrans(:,3))];
    end
    
    % if the print flag is enabled with varargin
    switch isempty(varargin)
        case 0
            switch varargin{1}
                case 'Print'
                    % open figures
                    fig1 = figure; 
                    % plot figures
                    fig1 = PlotMyThings(myUSImage,gridPoints,roundMRT,myOptGrid,fig1);
            end
        otherwise
            fig1 = NaN;
    end
    
end

function [figNo] = PlotMyThings(myUSImage,gridPoints,roundMRT,gps,figNo)
    %% nested function to plot the step through US point data on top of 
    % the ultrasound image
    
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
        
        for j = 1:3
            try
                if (i >= gps(j).SE(1)) && (i <= gps(j).SE(2))
                    
                    pltHand = plot(gps(j).bestPoints(:,1),gps(j).bestPoints(:,2),'sy');
                    pltHand.LineWidth = 1;
                end
            catch
            end
        end
        idx = find(roundMRT(:,3)==i);
        plot(roundMRT(idx,1),roundMRT(idx,2),'*')
        
        drawnow; pause;
        hold off
        
    end
end
