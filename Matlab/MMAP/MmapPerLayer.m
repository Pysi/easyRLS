classdef MmapPerLayer < handle
% the class MmapPerLayer is used to load a mmap of a binary series
% --- you can call the focused version ---
    properties
        mmaps % cell array of linear mmap
        pixtype % uint16 ou single
        space % ex: RAS or RAST depending on dimension
        indices % cell array of indices
        numIndex % cell array of numIndex
        x % width (left to right)
        y % height (posterior to anterior)
        z % number of layers (inferior to superior)
        t % number of time frames (per layer)
        Z % layers concerned (TODO make optionnal)
        T % times concerned (TODO remove it)
    end
    methods
        % --- constructor ---
        function self = MmapPerLayer(inPath)
        %MmapPerLayer looks for a collection of files containing linear mmaps
        
            binFile = fullfile(inPath, '*.bin');
            inputInfo = fullfile(inPath, '*.mat');
            
            matFiles = dir(inputInfo);
            
            % loads memory maps
            for matFile = matFiles'
                dffLayer = fullfile(matFile.folder, matFile.name);
                iz = sscanf(matFile.name, '%02d.mat');
                load(dffLayer, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'indices', 'numIndex');
                % mdff = recreateMmap(F,mmap); % should be done for relative path 
                mdff = mmap;
                self.mmaps{iz} = mdff;
                self.indices{iz} = indices;
                self.numIndex{iz} = numIndex;
            end
            
            % assume all x, y, z, t are the same
            self.x = x; 
            self.y = y; 
            self.z = z; 
            self.t = t; 
            self.Z = Z; 
            self.T = T; 
            
            % set space
            if t == 1
                self.space = 'RAS';
            else
                self.space = 'RAST';
            end
            
            % get pixtype
            self.pixtype = mdff.Format{1};
        end
        
        % --- defining '()' subsref ---
        function out = subsref(self, S)
        %subsref calls the mmap with the correct z index
            switch S(1).type
                case '()'
                    switch length(S(1).subs)
                        case 4 % 4D
                            error('4D subsref not implemented for MmapPerLayer');
                        case 3 % 3D with xy as index
                            % ok
                        otherwise
                            error('NUMBER OF SUBSCRIPT NOT COMPATIBLE possible calls : m(index,z,t)')
                    end
                    
                    % calls the right mmap
                    switch length(S(1).subs)
                        case 3 % 3D with xy as index
                            xy = S(1).subs{1};
                            z_ = S(1).subs{2};
                            t_ = S(1).subs{3};                
                            % if not RAS, return RAS instead !
                            switch self.space
                                case {'RAS', 'RAST'}
                                    % nothing
                                otherwise
                                    RAST = 'RAST';
                                    dim = 2; % only work on linear index
                                    [~,i,o] = getTransformation(self.space(1:dim), RAST(1:dim));
                                    xy = indTransform(xy, [self.x, self.y], i, o);
                            end
                            
                            if xy == ':'
                                out = self.mmaps{z_}.Data.bit(t_, xy);
                            else
                                % check if asked index is inside indices
                                assert(all(ismember(xy, self.indices{z_})));
                                % changes the value to position in mmap
                                mmapind = NaN(1, length(xy));
                                for i = 1:length(xy)
                                    mmapind(i) = find(self.indices{z_}==xy(i));
                                end
                                % calls mmap
                                out = self.mmaps{z_}.Data.bit(t_, mmapind);
                            end
                    end
                case '.'
                    out = builtin('subsref', self, S);
                otherwise
                    error('subsref other than () or . are not implemented')
            end        
        end
    end
end
            
