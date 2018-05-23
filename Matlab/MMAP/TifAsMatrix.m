classdef TifAsMatrix < handle
    %TifAsMatrix is analog to Mmap and Mmap on dcimg :
    % it is a wrapper to access tif stack as a 4D RAS matrix
    % it is not memory mapping, but simplifies the function that work with 4D matrix
    
%     there is no focused version of this since it is already focused
    
    properties
        space % RAS or RAST
        x % width
        y % height
        z % number of layers
        t % number of time frame
        Z % layers concerned
        T % times concerned
    end
    properties (Hidden) % no need to see this
        f % list of transformations to apply
        F % Focus (TODO chek if not a problem)
    end
    methods
        % --- constructor ---
        function self = TifAsMatrix(F)
            
            inMode= 'ALIT'; % TODO get in focus
            outMode = 'RAST';
            
            [self.f, inversions, order] = getTransformation(inMode, outMode);
            invertZ = inversions(3); % /!\ assuming z is 3rd dimension
            invertXY = ( order(1)==2 ); % /!\ assuming x and y are 1st and 2nd    

            % defines X and Y    
            %     in 'update_info'
            %     this.height = size(this.pix, 1);
            %     this.width = size(this.pix, 2);
                if invertXY
                    x = F.IP.height;          % x size (first dimension) = rows 'Y'
                    y = F.IP.width;           % y size (second dimension) = cols 'X'
                else
                    y = F.IP.height;          % x size (first dimension) = rows 'Y'
                    x = F.IP.width;           % y size (second dimension) = cols 'X'
                end
            % defines Z
                if invertZ
                    Z = flip([F.sets.id]);
                else
                    Z = [F.sets.id];
                end
            
            self.space = inMode;
            self.x = x; 
            self.y = y; 
            self.z = length(Z); 
            self.t = F.param.NCycles; 
            self.Z = Z; 
            self.T = 1:self.t; 
            
            self.F = F;
            
            warning('you are working with TIF (no memory mapping) which are %s but will return RAST', self.space);
        end
        
        % --- defining '()' subsref ---
        function out = subsref(self, S)
        %subsref calls the mmap with the correct z index
            switch S(1).type
                case '()'
                    % get dimensions from subs
                    X = S(1).subs{1};
                    Y = S(1).subs{2};
                    Z = S(1).subs{3}; %#ok<*PROPLC>
                    T = S(1).subs{4}; % loop on T not implemented yet
                    t = T;
                    
                    % if ':', select all
                    if X == ':'
                        X = 1:self.x;
                    end
                    if Y == ':'
                        Y = 1:self.y;
                    end 
                    
                    out = NaN(length(X), length(Y), length(Z), 1);
                    
                    for i = 1:length(Z)
                        self.F.select(self.F.sets(Z(i)).id);
                        imgName = self.F.imageName(t);
                        % % % when doing imread, the number of columns 'X', is the second
                        % % % dimension of the matrix and corresponds to the 'x' in imageJ
                        tmp = imread(imgName)';     % reads image (sometimes very long ??)
                                                    % then transpose to make 1rst
                                                    % dimension being x
                                                    % see benchmark at the end
                        pix = applyTransformation(tmp, self.f); % ~
                        out(:,:,i) = pix(X,Y);
                        out = squeeze(out);
                    end
                    
                case '.'
                    out = builtin('subsref', self, S);
                otherwise
                    error('subsref other than () or . are not implemented')
            end        
        end
        
    end
    
end