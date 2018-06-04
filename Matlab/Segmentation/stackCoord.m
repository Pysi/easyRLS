function stackCoord(F)
% takes coords from specified layers in pixel and stack them in a single file in microns
% /!\ for z computation, highest value of 'layers' must correspond to first layer in nrrd
% (e.g. z = 20 corresponds to z = 0 µm)

    segPath = F.dir('Segmentation');
    
    coordinates = NaN(0,3); % 0 neurons (x y z)
    
    Layers = F.Analysis.Layers; % loads the layers ids to concatenate
    if ~issorted(Layers)
        warning('layers IDs asked not sorted, RAS might not be respected');
    end
    assert(F.dx==F.dy, 'pixel sizes are not defined or not equal');
    
    for zid = Layers
        inSeg = fullfile(segPath, [num2str(z, '%02d') '.mat']);
        load(inSeg, 'centerCoord', 'numberNeuron'); % loads coordinates in pixel
        zorder = (Mmap.zCorrect(zid, Layers) -1 ) ; % converts the id to an order
        % (example : layer 20 is the number 0)
        zmum = zorder * abs(F.param.Increment); % converts z in µm
        coordinates = [coordinates ; ...
            [F.dx * centerCoord ... % x and y pixel size are supposed to be equal
            zmum * ones(numberNeuron, 1)]];
        % concatenates all z for corresponding x and y
    end
    
    numberNeuron = size(coordinates, 1); % updates total number of neurons
    
    outCoord = fullfile(segPath, 'coordinates.mat');
    save(outCoord, 'coordinates', 'numberNeuron');
end