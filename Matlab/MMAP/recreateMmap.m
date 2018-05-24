function mmapOut = recreateMmap(F, mmapIn)
%recreateMmap(F, mmapIn) recreates a memory map from the existing one
% it avoids problem of absolute path stored in memory map (which breaks the 
% mmap if the folder was moved)
% F is the focus object to rebuild path
% mmapIn it the input memory map to redefine

p = split(mmapIn.Filename, 'Analysis/'); % gets the relative part of the path
relPath = p{end}; % takes the end
binFile = fullfile(F.dir('Analysis'), relPath);

mmapOut = memmapfile(...
                binFile,...
                'Format',mmapIn.Format...
                );

end