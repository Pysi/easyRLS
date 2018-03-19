function m = Mmap(F, tag)
% the function Mmap calls the constructor of the class Mmap with focused arguments

    inputFile = fullfile(F.dir.files, tag); % TODO know automatically location thanks to tag 
    
    m = Mmap(inputFile);
    
end
    
