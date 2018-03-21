classdef MmapOnDCIMG < handle
% the class MmapOnDCIMG is used to create a mmap on a dcimg stack
% and to interact with normal subscripts (x,y,z,t), (xy, z, t)
% without thinking about header and clockskip
% it makes possible to use a dcimg as a standard stack
    properties
        mmaplin % 3D mmap of the dcimage (xy+clockskip, z, t)
        x % width
        y % height
        z % number of layers
        t % number of time frame
        Z % layers concerned
        T % times concerned
    end
    methods
        function self = MmapOnDCIMG(inputPathTag)
        %Mmap constructor takes the bin file and the info file
        %inputFile is the input file (without extension)    
            
            binFile = [inputPathTag '.dcimg'];
            inputInfo = [inputPathTag '.mat'];
            
            load(inputInfo, 'x', 'y', 'z', 't', 'Z', 'T', 'byteskip', 'clockskip');
            self.mmaplin = dcimgToMmap(binFile, '', x, y, z, t, byteskip, clockskip, false);
            self.x = x; 
            self.y = y; 
            self.z = z; 
            self.t = t; 
            self.Z = Z; 
            self.T = T; 
        end
        
        function out = subsref(self, S)
        %subsref calls the mmap with the correct z index
            switch S(1).type
                case '()'
                    newS = S;
                    switch length(S(1).subs)
                        case 4 % 4D
                            newS(1).subs = cell(1,3); 
                            x = S(1).subs{1}; 
                            y = S(1).subs{2};
                            newS(1).subs{2} = S(1).subs{3}; % z
                            newS(1).subs{3} = S(1).subs{4}; % t
                            
                            if x == ':'
                                x = 1:self.x;
                            end
                            if y == ':'
                                y = 1:self.y;
                            end                            
                            
                            [X,Y] = meshgrid(x, y);
                            xy = sub2ind([self.x self.y], X, Y);
                            
                            newS(1).subs{1} = xy; % xy
                            
                            askedSize = [size(xy), length(newS(1).subs{2}), length(newS(1).subs{3})]; % weak point !
                            out = reshape(subsref(self.mmaplin.Data.bit, newS), askedSize);
                        case 3 % 3D with xy as index
                            xy = S(1).subs{1}; 
                            
                            if xy == ':'
                                xy = 1:self.x;
                            end
                            
                            newS(1).subs{1} = xy; % xy
                            
                            out = subsref(self.mmaplin.Data.bit, newS);
                    end
                case '.'
                    out = builtin('subsref', self, S);
                otherwise
                    error('subsref other than () or . are not implemented')
            end        
        end
        
    end
    
end
        
            