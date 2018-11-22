function m = Mmap(F, tag, writable)
%Focused the function Mmap calls the constructor of the class Mmap with focused arguments

    % default is read only
    if ~exist('writable', 'var')
         writable = false;
    end
    
    tomlFile = [F.tag(tag) '.toml'];
    
    if ~exist(tomlFile, 'file')
        error('toml file needed for memory map')
    end
    
    m = Mmap(F.tag(tag), writable);
    
end
    
