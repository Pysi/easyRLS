function parallelDriftApply(F, Layers)

if ~exist('layers', 'var')
     Layers = F.Analysis.Layers;
end

Focused.mkdir(F, 'corrected', true);
m = adapted4DMatrix(F, 'source'); 
Z = sort(Layers, 'descend');
outputInfo = [F.tag('corrected') '.toml'];
if ~exist('outputInfo', 'file')
    writeINFO(outputInfo, m.x, m.y, length(Layers), m.t, Z, m.space, 'uint16');
end
corr = adapted4DMatrix(F, 'corrected', true); % allocate

parfor i = F.Analysis.Layers
    pardriftApply(F, i)
end

end


function pardriftApply(F, layer)    
    % load drift
    driftPath = fullfile(F.dir('Drift'), 'Drifts.mat');
    load(driftPath, 'dx', 'dy')

    % load mmap info
    m = adapted4DMatrix(F, 'source'); 
    
    % define output
    mcorr = adapted4DMatrix(F, 'corrected', true); % create writable memory map

    % write the binary file
    for t = m.T % along t
        if ~mod(t,100); fprintf("%d: %d\n", layer, t); end
        mcorr(:,:,layer,t) = imtranslate(m(:,:,layer,t), [-dy(layer,t), -dx(layer,t)]);
    end
end