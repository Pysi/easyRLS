function mmap = dcimgToMmap(inputFile, outputDir, x, y, z, t, byteskip, clockskip, doIt)
%dcimgToMmap maps the binary part of the dcimg image
% dcimg (digital camera images) are composed of a header, frames, and timestamps
% inputFile
% outputDir
% x
% y
% z
% t
% byteskip = header size (byte)
% clockskip = clock size (byte)
% doIt = either true or false. true if you want to create a bin file

% create mmap
mmap = memmapfile(inputFile, ...
    'Format', {'uint16', [x*y+clockskip, z, t], 'bit'},...
    'Offset', byteskip);

if doIt % if the user asks to create the file
    output = fullfile(outputDir, 'raw.bin');
    outputInfo = fullfile(outputDir, 'raw.mat');
    
    Z = 1:z;
    T = 1:t;

    w = waitbar(0, 'Converting DCIMG to bin');

    % write the binary file
    fid = fopen(output, 'wb');
    for i_t = T % along t
        waitbar(i_t/t)
        for i_z = Z % along z
            fwrite(fid, mmap.Data.bit(1:x*y, i_z, i_t),'uint16');
        end
    end
    fclose(fid);

    close(w)
    
    % save info to a matlab file
    save(outputInfo, 'x', 'y', 'z', 't', 'Z', 'T');
end

end
