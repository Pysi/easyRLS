function m = Mmap(F, tag, writable)
%Focused the function Mmap calls the constructor of the class Mmap with focused arguments

    % default is read only
    if ~exist('writable', 'var')
         writable = false;
    end
    
    m = Mmap(F.tag(tag), writable);
    
end
    
