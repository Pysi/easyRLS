function driftApply(F, tag)
%driftApply(F) creates a binary file with the translated values

    % load drift
    driftPath = fullfile(F.dir('Drift'), 'Drifts.mat');
    load(driftPath, 'dx', 'dy')

    % load mmap info
    m = adapted4DMatrix(F, tag);

    % define output files
    mkdir(F.dir('corrected'));
    output = [F.tag('corrected') '.bin'];
    outputInfo = [F.tag('corrected') '.mat'];

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
    space = m.space;
    
    % save info to a matlab file
    writeNHDR(F, 'corrected');
    save(outputInfo, 'x', 'y', 'z', 't', 'Z', 'T', 'space');

end