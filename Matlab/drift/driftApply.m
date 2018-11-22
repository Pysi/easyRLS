function driftApply(F, layers)
%driftApply(F) creates a binary file with the translated values

    Focused.mkdir(F, 'corrected', true);
    
    % get layers to analyse
    if ~exist('layers', 'var')
        layers = F.Analysis.Layers;
    end
    Z = sort(F.Analysis.Layers, 'descend'); % Z stored in info
    
    % load drift
    driftPath = fullfile(F.dir('Drift'), 'Drifts.mat');
    load(driftPath, 'dx', 'dy')

    % load mmap info
    m = adapted4DMatrix(F, 'source'); 
    
    % save info to a matlab file if not existing
    outputInfo = [F.tag('corrected') '.toml'];
    if ~exist(outputInfo, 'file')
        writeINFO(outputInfo, m.x, m.y, length(F.Analysis.Layers), m.t, Z, m.space, 'uint16');
    end    
    
    % define output
    mcorr = adapted4DMatrix(F, 'corrected', true); % create writable memory map

    % write the binary file
    for t = m.T % along t
        if ~mod(t,100); fprintf("%d\n", t); end
        for z = layers % along z
            mcorr(:,:,z,t) = imtranslate(m(:,:,z,t), [-dy(z,t), -dx(z,t)]);
        end
    end
end