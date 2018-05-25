function driftApply(F, tag)
%driftApply(F) creates a binary file with the translated values

    % get layers to analyse and put them in inferior to superior order
    Z = F.Analysis.Layers;
    Z = sort(Z, 'descend');

    % load drift
    driftPath = fullfile(F.dir('Drift'), 'Drifts.mat');
    load(driftPath, 'dx', 'dy')

    % load mmap info
    m = adapted4DMatrix(F, tag);

    % define output files
    mkdir(F.dir('corrected'));
    output = [F.tag('corrected') '.bin'];
    outputInfo = [F.tag('corrected') '.mat'];

    w = waitbar(0, {'Applying computed drift', ['frame ' num2str(0) '/' num2str(m.t)]});

    % write the binary file
    fid = fopen(output, 'wb');
    for t = m.T % along t
        for z = Z % along z
            fwrite(fid,...
                imtranslate(m(:,:,z,t),...
                [-dy(t), -dx(t)]),... %  'x' of a matlab image is 'y'
                'uint16'); % apply dy on rows (y) and dx on columns (x)
        end
        waitbar(t/m.t, w, {'Applying computed drift', ['frame ' num2str(t) '/' num2str(m.t)]})
    end
    fclose(fid);

    close(w)

    x=m.x; %#ok<*NASGU>
    y=m.y;
%     z=m.z;
    z=length(Z);
    t=m.t;
%     Z=m.Z;
    T=m.T;
    space = m.space;
    pixtype='uint16';
    
    % save info to a matlab file
    save(outputInfo, 'x', 'y', 'z', 't', 'Z', 'T', 'space','pixtype');
    writeNHDR(F, 'corrected');

end