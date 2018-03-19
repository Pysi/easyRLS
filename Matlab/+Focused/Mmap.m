function m = Mmap(F, tag)
% the function Mmap calls the constructor of the class Mmap with focused arguments

    binFile = fullfile(F.dir.files, [tag '.bin']); % TODO know automatically location thanks to tag 
    inputInfo = fullfile(F.dir.files, [tag '.mat']); % TODO know automatically location thanks to tag
    m = Mmap(binFile, inputInfo);
    
end
    
