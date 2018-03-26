function mmapOut = recreateMmap(F, mmapIn)
%recreateMmap recreates a memory map
% it avoids problem of absolute path stored in memory map
% (which breaks the mmap if the folder was moved)

p = split(mmapIn.Filename, 'Files/'); % gets the relative part of the path
relPath = p{end}; % takes the end
binFile = fullfile(F.dir.files, relPath);

mmapOut = memmapfile(...
                binFile,...
                'Format',mmapIn.Format...
                );

end