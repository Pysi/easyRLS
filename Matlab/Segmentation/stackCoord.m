function stackCoord(F)
% takes coords from specified layers in pixel and stack them in a single file in microns
% /!\ for z computation, highest value of 'layers' must correspond to first layer in nrrd
% (e.g. z = 20 corresponds to z = 0 µm)

    segPath = F.dir('Segmentation');
    
    coordinates = NaN(0,3); % 0 neurons (x y z)
    
    Layers = F.Analysis.Layers; % loads the layers ids to concatenate
    assert(F.dx==F.dy, 'pixel sizes are not defined or not equal');
    
    for zid = Layers % Layers should be sorted (ex 3 4 5 ... 19 20)
        inSeg = fullfile(segPath, [num2str(zid, '%02d') '.mat']);
        load(inSeg, 'centerCoord', 'numberNeuron'); % loads coordinates in pixel
        zorder = (Mmap.zCorrect(zid, flip(Layers)) -1 ) ; % converts the id to an order
        % (example : layer 20 is the number 0)
        zmum = zorder * abs(F.param.Increment); % converts z in µm
        coordinates = [coordinates ; ...
            [F.dx * centerCoord(:,2) ... % x
             F.dy * centerCoord(:,1) ... % y
            zmum * ones(numberNeuron, 1)]]; % z
        % don't forget that x and y are inverted in Matlab
    end
    
    numberNeuron = size(coordinates, 1); % updates total number of neurons
    
    outCoord = fullfile(segPath, 'coordinates.mat');
    save(outCoord, 'coordinates', 'numberNeuron');
end