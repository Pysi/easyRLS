function exportToHDF5(F)
% export to hdf5 file

    fileName = fullfile(F.dir.data, [erase(F.name, ' ') '.h5']);

    load(fullfile(F.dir.IP, 'Segmented', 'coordinates.mat'), 'coordinates', 'numberNeuron');
    load(fullfile(F.dir.RefBrain, 'refCoordinates.mat'), 'refCoordinates');
    timeFrames = 3000;
    calciumActivity = [];

    % concatenate neurons activity
    for iz = 3:12
        dffPath = fullfile(F.dir.IP, 'dff_neuron', [num2str(iz, '%02d') '.mat']);
        load(dffPath, 'mmap');
        mdff = recreateMmap(F,mmap); clear('mmap');

        calciumActivity = [calciumActivity; mdff.Data.bit(:,:)'];
    end

    h5create(fileName,'/Data/Coordinates', [numberNeuron 3]); % xyz = 3 coordinates
    h5write(fileName,'/Data/Coordinates', coordinates ./ 1000); % µm → mm
    h5writeatt(fileName,'/Data/Coordinates','unit', 'mm')
    h5writeatt(fileName,'/Data/Coordinates','orientation', 'RAS')

    h5create(fileName,'/Data/RefCoordinates', [numberNeuron 3]);
    h5write(fileName, '/Data/RefCoordinates', refCoordinates ./ 1000);
    h5writeatt(fileName,'/Data/RefCoordinates','unit', 'mm')
    h5writeatt(fileName,'/Data/RefCoordinates','orientation', 'RAS')

    h5create(fileName,'/Data/Times', [1 timeFrames]);
    dtframe = F.dt / 1000 * F.param.NLayers ;
    h5write(fileName,'/Data/Times', 0: dtframe : dtframe*(timeFrames-1)  ); % ms → s 
    h5writeatt(fileName,'/Data/Times','unit', 's')

    %h5create(FileName,'/Data/Behavior', [Range,3]);
    %h5write(FileName,'/Data/Behavior', Behavior);

    h5create(fileName,'/Data/Values', [numberNeuron, timeFrames]);
    h5write(fileName,'/Data/Values', calciumActivity);
    h5writeatt(fileName,'/Data/Values','type', 'DFF, single')

    % h5create(fileName,'/Data/Stimulus', [Range,1]);
    % h5write(fileName,'/Data/Stimulus', Stimulus);

    % h5create(fileName, '/Data/ZBrainAtlas_Labels', [NCells, labels_size(2)]);
    % h5write(fileName, '/Data/ZBrainAtlas_Labels', Labels);

    clear calciumActivity

end