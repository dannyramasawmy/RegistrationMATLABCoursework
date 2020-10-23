function [myInterMask] = InterpolateBinaryImage(myInputMasks, varargin)
    %  Created February 2016
    % Student Number: 15102411
    %
    % INPUT:
    %   The input to the binary image is the myMask object, which has the
    %   binary image volume and the relative pixel dimensions, and the inter
    %   slice spacing. The is an extra input which allows the user to choose a
    %   different interpolating type, here only linear or cubic.
    %
    % PROCESS:
    %   The function takes the mask, and shells it to get the perimeter using
    %   the bwperim function. Once the perimeter is found, bwdist calculates
    %   the distance cloest to the surface for each slice. If there is nothing
    %   on the slice apart from zeros the slice is ignored, otherwise inf
    %   values will occur. The ratio between i,j and z dimensions is found to
    %   interpolate between points and give isotropic dimensions. This is done
    %   pixel by pixel using interp1.It can do multiple processing of high
    %   dimensional objects.
    %
    % OUTPUT:
    %   The output is a similar object to the input mask, and has two
    %   attributes:
    %       myInterMask.volume : isotropic binary image m * n *z
    %       myInterMask.dimensions : dimensions of voxel, will all be the same
    %       ie. [0.4 0.4 0.4]
    %
    % DESCRIPTION
    %   The purpose of this function is to ake the voxel dimensions isotropic.
    %   They are isotropic in i and j and need to be made isotropic in z to make
    %   them more useable.
    %
    
    %% Loop over every
    for object =1:length(myInputMasks);
        
        % assign a temporayr mask variable
        myMasks = myInputMasks(object).volume;
        
        % assign dimensions
        pixSpace = myInputMasks(1).dimensions(1)/...
            (myInputMasks(1).dimensions(3) + myInputMasks(1).SliceSpacing);
        
        % send output
        myInterMask(object).dimensions = [myInputMasks(1).dimensions(1:2),myInputMasks(1).dimensions(1)];
        
        % Check if they want cubic or linear
        switch isempty(varargin{1})
            case 1
                % set method to linear if not specified
                method = 'linear';
            otherwise
                switch varargin{1};
                    case 'Cubic'
                        % set method to cubic, pchip is the new cubic flag
                        method = 'pchip';
                    otherwise
                        % set method to linear
                        method = 'linear';
                end
        end
        
        % Display some useful messages
        disp([' Using a,',method,' spline for interpolation']);
        
        
        %% Calculated the signed distance
        for mind = 1:size(myMasks,3);
            % if the slice is all 0, then ignore it
            if sum(sum(myMasks(:,:,mind))) ~= 0;
                
                % create the inside mask, 1's inside contour
                myMaskIn = myMasks(:,:,mind);
                
                % creat an outside masks, 1's outside contour
                myMaskOut = imcomplement(myMasks(:,:,mind));
                
                % calculate signed distance to the perimeter
                signedDist = bwdist(bwperim(myMaskIn));
                
                % make outside negative
                outer = myMaskOut.*signedDist;
                
                % make inside positive
                inner = myMaskIn.*signedDist;
                
                % add them together to get negative outside, =ve inside
                totes = outer*-1 + inner;
                
            else
                
                % slice all 0's so ignore it
                totes = myMasks(:,:,mind);
            end
            
            % assign to
            mySigned(:,:,mind) = totes;
        end
        
        
        %% Interpolating
        % loop over every pixel
        for ipix = 1:size(myMasks,1)
            for jpix = 1:size(myMasks,2)
                
                % get a vector
                v = squeeze(mySigned(ipix,jpix,:));
                
                % get a vector of the same length, just for interpolating
                x = (1:length(v))';
                
                % set the intervals wanted from pixSpacing
                xq = 1:pixSpace:x(end);
                
                % interpolate with chose method
                vq = interp1(x,v,xq,method);
                
                % assign the new vector for a pixel in the volume
                myInterMaskTemp(ipix,jpix,:) = vq;
            end
        end
        
        %% Make positive and negative
        
        % make negative 0, and positive 1
        myInterMaskTemp(myInterMaskTemp<0)=0;
        myInterMaskTemp(myInterMaskTemp>0)=1;
        
        % output
        myInterMask(object).volume = myInterMaskTemp;
    end
end

