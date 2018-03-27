function mmap = dcimgToMmap(inputFile, x, y, z, t, byteskip, clockskip)
%dcimgToMmap returns a memory map on the data part of the dcimg
% dcimg (digital camera images) are composed of a header, frames, and timestamps
% inputFile is the input binary file
% x
% y
% z
% t
% byteskip = header size (byte)
% clockskip = clock size (byte)

% create mmap
mmap = memmapfile(inputFile, ...
    'Format', {'uint16', [x*y+clockskip, z, t], 'bit'},...
    'Offset', byteskip,...
    'Repeat', 1);

end
