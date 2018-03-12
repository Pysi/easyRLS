function mmap = dcimgToMmap(F, tag, kwargs)
%dcimgToMmap maps the binary part of the dcimg image according to the given kwargs
% dcimg (digital camera images) are composed of a header, frames, and timestamps

% define default values
byteskip = 808;
clockskip = 8;
x = 1024;
y = 600;
z = 20;
t = 1500;

% parse input
in = inputParser;
in.addParameter('byteskip', byteskip);
in.addParameter('clockskip', clockskip);
in.addParameter('x', x);
in.addParameter('y', y);
in.addParameter('z', z);
in.addParameter('t', t);
in.addParameter('do', false);
in.parse(kwargs{:})

% get results
byteskip = in.Results.byteskip;
clockskip = in.Results.clockskip;
x = in.Results.x;
y = in.Results.y;
z = in.Results.z;
t = in.Results.t;

% create mmap
inputFile = fullfile(F.dir.data, [tag '.dcimg']);
mmap = memmapfile(inputFile, ...
    'Format', {'uint16', [x*y+clockskip, z, t], 'bit'},...
    'Offset', byteskip);

if in.Results.do % if the user asks to create the file
    output = fullfile(F.dir.files, 'raw.bin');
    outputInfo = fullfile(F.dir.files, 'raw.mat');
    
    Z = 1:z;
    T = 1:t;

    w = waitbar(0, 'Converting DCIMG to bin');

    % write the binary file
    fid = fopen(output, 'wb');
    for i_t = T % along t
        for i_z = Z % along z
            fwrite(fid, mmap.Data.bit(1:x*y, i_z, i_t),'uint16');
            waitbar(i_t/t)
        end
    end
    fclose(fid);

    close(w)
    
    % save info to a matlab file
    save(outputInfo, 'x', 'y', 'z', 't', 'Z', 'T');
end

end