classdef MmapOnDCIMG < handle
% the class MmapOnDCIMG is used to create a mmap on a dcimg stack
% and to interact with normal subscripts (x,y,z,t), (xy, z, t)
% without thinking about header, clockskip, and RAS orientation
% it makes possible to use a dcimg as a standard RAS stack
    properties
        mmaplin % 3D mmap of the dcimage (xy+clockskip, z, t)
        space % RAST
        x % width (left to right)
        y % height (posterior to anterior)
        z % number of layers (inferior to superior)
        t % number of time frames (per layer)
        Z % layers concerned (TODO make optionnal)
        T % times concerned (TODO remove it)
    end
    properties (Hidden) % no need to see this
        f % list of transformations to apply
        inv % inversions
        ord % order
        origSpace % space of input DCIMG file (ALIT for instance)
    end
    
    methods
        function self = MmapOnDCIMG(inputPathTag)
        %Mmap constructor takes the bin file and the info file
        %inputFile is the input file (without extension)    
            
            binFile = [inputPathTag '.dcimg'];
            inputInfo = [inputPathTag '.mat'];
            
            load(inputInfo, 'x', 'y', 'z', 't', 'Z', 'T', 'byteskip', 'clockskip','origSpace');
            self.mmaplin = dcimgToMmap(binFile, x, y, z, t, byteskip, clockskip);
            self.space = 'RAST';
            %#ok<*PROPLC>
            self.x = x; 
            self.y = y; 
            self.z = z; 
            self.t = t; 
            self.Z = Z; 
            self.T = T; 
            self.origSpace = origSpace;
           
            % generate transformations
            [self.f, self.inv, self.ord] = getTransformation(self.origSpace, self.space);
        end
        
        function out = subsref(self, S)
        %subsref calls the mmap with the correct z index
            
            switch S(1).type
                case '()'
                    newS = S;
                    switch length(S(1).subs)
                        case 4 % 4D
                            newS(1).subs = cell(1,3); 
                            
                            % get subs in natural order and prepare new subs
                            x = S(1).subs{1}; 
                            y = S(1).subs{2};
                            newS(1).subs{2} = S(1).subs{3}; % z
                            newS(1).subs{3} = S(1).subs{4}; % t
                            
                            % if subs are not explicit, make them explicit
                            if x == ':'
                                x = 1:self.x;
                            end
                            if y == ':'
                                y = 1:self.y;
                            end                            
                            
                            % apply reverse coordinates transformation
                            % TODO put this in a function
                            if self.inv(1) % if x are inverted
                                x = self.x - x + 1;
                            end
                            if self.inv(2) % if y are inverted
                                y = self.y - y + 1;
                            end
                            % if subscribts are not ordered, the result will not be RAST
                            
                            % creates the X Y coordinates
                            [X,Y] = meshgrid(x, y);
                            
                            % TODO make this more general
                            if self.ord(1) == 1 % good order
                                xy = sub2ind([self.x self.y], X, Y);
                            else % bad order
                                xy = sub2ind([self.y self.x], Y, X);
                            end
                            
                            newS(1).subs{1} = xy'; % (matlab inverses x and y)
                            
                            % we want to return a [x,y,z,t] sized matrix
                            askedSize = [length(x), length(y), length(newS(1).subs{2}), length(newS(1).subs{3})];
                            out = reshape(subsref(self.mmaplin.Data.bit, newS), askedSize);
                            
                            % out = applyTransformation(out, self.f);
                            % no need to apply transformation since we did
                            % it on coordinates
                            % TODO: this has to be tested !! it is only a draft
                            
                        % TODO make RAS returned for linear indexing too
                        case 3 % 3D with xy as index
                            xy = S(1).subs{1}; 
                            % if everything
                            if xy == ':'
                                xy = 1:self.x*self.y;
                            end
                            
                            % translate the xy index back to RA(ST)
                            xy = indTransform(xy, [self.x, self.y], self.inv(1:2), self.ord(1:2)); % only 2D index transformation
                            
                            newS(1).subs{1} = xy; % xy
                            
                            out = subsref(self.mmaplin.Data.bit, newS);
                            
                        otherwise
                            error('not implemented');
                    end
                case '.'
                    out = builtin('subsref', self, S);
                otherwise
                    error('subsref other than () or . are not implemented')
            end        
        end
        
    end
    
end
        
            
