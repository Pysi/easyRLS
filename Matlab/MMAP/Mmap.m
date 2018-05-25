classdef Mmap < handle
% the class Mmap is used to load a mmap of a binary file
% and redefine layers index when called as subscript
% subscript can be 4D or 3D
% --- you can call the focused version of Mmap : Focused.Mmap ---
    properties
        mmap % 4D mmap (x,y,z,t)
        mmaplin % 3D mmap of *the same* binary file (xy, z, t)
        pixtype % uint16 ou single
        space % RAS or RAST depending on dimension
        x % width (left to right)
        y % height (posterior to anterior)
        z % number of layers (inferior to superior)
        t % number of time frames (per layer)
        Z % layers concerned (TODO make optionnal)
        T % times concerned (TODO remove it)
    end
    methods
        % --- constructor ---
        function self = Mmap(inPathTag)
        %Mmap constructor takes the bin file and the info file
        %inputFile is the input file (without extension)
        
            binFile = [inPathTag '.bin'];
            inputInfo = [inPathTag '.mat'];
            
            load(inputInfo, 'x', 'y', 'z', 't', 'Z', 'T', 'space','pixtype');
            self.pixtype = pixtype; % get type
            self.space = space; % RAS or RAST
            self.mmap = ...
                memmapfile(binFile,'Format',{self.pixtype,[x,y,z,t],'bit'}, ...
                    'Repeat', 1); % repeat option might prevent from detecting errors (such on t)
            self.mmaplin = ...
                memmapfile(binFile,'Format',{self.pixtype,[x*y,z,t],'bit'}, ...
                    'Repeat', 1);
            self.x = x; 
            self.y = y; 
            self.z = z; 
            self.t = t; 
            self.Z = Z; 
            self.T = T; 
        end
        
        % --- defining '()' subsref ---
        function out = subsref(self, S)
        %subsref calls the mmap with the correct z index
            switch S(1).type
                case '()'
                    switch length(S(1).subs)
                        case 4 % 4D
                            zpos = 3; % position of the z coordinate in the subscript
                        case 3 % 3D with xy as index
                            zpos = 2; % position of the z coordinate in the subscript
                        otherwise
                            error('NUMBER OF SUBSCRIPT NOT COMPATIBLE possible calls : m(x,y,z,t) or m(index,z,t)')
                    end
                    % corrects the z
                    old_z = S.subs{zpos}; % values asked ex layers [4 5 6]
                    new_z = self.zCorrect(old_z, self.Z); % values corrected ex index [2 3 4]
                    new_S = S; % (avoid illegal use of subscript parameter)
                    new_S(1).subs{zpos} = new_z; % replace the z in the subscript
                    
                    % calls the right mmap
                    switch length(S(1).subs)
                        case 4 % 4D
                            out = subsref(self.mmap.Data.bit, new_S);
                        case 3 % 3D with xy as index
                            out = subsref(self.mmaplin.Data.bit, new_S);
                    end
                case '.'
                    out = builtin('subsref', self, S);
                otherwise
                    error('subsref other than () or . are not implemented')
            end        
        end
    end
    
    methods (Static)        
        % --- redefining z --- TODO take into account not well ordered Zs
        % (return RAS whatever the input is, with warning in not RAS asked)
        function new_z = zCorrect(old_z, Z)
        %zCorrect returns z compatible with mmap
        % examples :
        % EX1
        % Z = [ 3 4 5 6 7 8 9 10 ]
        % input is 4 5 6
        % output should be 2 3 4
        % EX2
        % Z = [ 10 9 8 7 6 5 4 3 ]
        % input is 4 5 6
        % output should be 5 6 7

            new_z = NaN(size(old_z)); % values corrected ex [2 3 4]
            for i = 1:length(old_z)
                try
                    new_z(i) = find(Z == old_z(i));
                catch
                    error('INDEX OUT OF RANGE : trying to reach layers outside mmap\n    asked : %s\n    available : %s', num2str(old_z), num2str(Z))
                end
            end
        end
    end
end
        
            
