function driftApply(F)
%driftApply creates a binary file with the translated values

    % load drift
    driftPath = fullfile(F.dir.IP, 'Drifts.mat');
    load(driftPath, 'dx', 'dy')

    % load mmap info
    m = Focused.Mmap(F, 'raw');

    % define output files
    output = fullfile(F.dir.files, 'corrected.bin');
    outputInfo = fullfile(F.dir.files, 'corrected.mat');

    w = waitbar(0, 'Applying computed drift');

    % write the binary file
    fid = fopen(output, 'wb');
    for t = m.T % along t
        for z = m.Z % along z
            fwrite(fid,...
                imtranslate(m(:,:,z,t),...
                [-dy(t), -dx(t)]),... %  'x' of a matlab image is 'y'
                'uint16'); % apply dy on rows (y) and dx on columns (x)
        end
        waitbar(t/m.t)
    end
    fclose(fid);

    close(w)

    x=m.x; %#ok<*NASGU>
    y=m.y;
    z=m.z;
    t=m.t;
    Z=m.Z;
    T=m.T;
    
    % save info to a matlab file
    save(outputInfo, 'x', 'y', 'z', 't', 'Z', 'T');

end