function mmap = dcimgToMmap(inputFile, x, y, z, t, header, clock)
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

clockskip = clock / 2; % clock is given in bytes (8 bits), clockskip is given in uint16 (16 bits)

mmap = memmapfile(inputFile, ...
    'Format', {'uint16', [x*y+clockskip, z, t], 'bit'},...
    'Offset', header,...
    'Repeat', 1);

end
