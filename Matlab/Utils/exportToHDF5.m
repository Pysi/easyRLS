function exportToHDF5(F)
% export to hdf5 file

    % shorten refBrainName
    sp = split(F.Analysis.RefBrain, '.');
    refBrainName = sp{1};
    
    % make dirctory 'HDF5' and create a h5 file in it
    Focused.mkdir(F, 'HDF5');
    fileName = fullfile(F.dir('HDF5'), [erase(F.name, ' ') '.h5']);

    % load coordinates, reference coordinates, and initialize data
    load(fullfile(F.dir('Segmentation'), 'coordinates.mat'), 'coordinates', 'numberNeuron');
    load(fullfile(F.dir('Registration'), ['coordinates_' refBrainName '.mat']), 'refCoordinates');
    NCycles = F.param.NCycles;
    calciumActivity = [];

    % === concatenate neurons activity
    for iz = F.Analysis.Layers
        dffPath = fullfile(F.dir('DFFNeuron'), [num2str(iz, '%02d') '.mat']);
        load(dffPath, 'mmap'); mdff = recreateMmap(F,mmap); clear('mmap'); % loads mmap and recreate it
        calciumActivity = [calciumActivity; mdff.Data.bit(:,:)'];
    end

    % === load and interpolate stimulus according to image acquisition time points
    load(fullfile(F.dir('Run'), 'Stimulus.txt')); % loads a text file
    time_exp = Stimulus(:, 2);
    Stimulus = Stimulus(:, 3);
    time_range = linspace(min(time_exp), max(time_exp), NCycles);
    Stimulus = interp1(time_exp, Stimulus, time_range);
    
    % === write to HDF5 file
    h5create(fileName,'/Data/Coordinates', [numberNeuron 3]); % xyz = 3 coordinates
    h5write(fileName,'/Data/Coordinates', coordinates ./ 1000); % µm → mm
    h5writeatt(fileName,'/Data/Coordinates','unit', 'mm')
    h5writeatt(fileName,'/Data/Coordinates','orientation', 'RAS')
    
    h5create(fileName,'/Data/RefCoordinates', [numberNeuron 3]);
    h5write(fileName, '/Data/RefCoordinates', refCoordinates ./ 1000);
    h5writeatt(fileName,'/Data/RefCoordinates','unit', 'mm')
    h5writeatt(fileName,'/Data/RefCoordinates','orientation', 'RAS')

    h5create(fileName,'/Data/Times', [1 NCycles]);
    dtframe = F.dt / 1000 * F.param.NLayers ;
    h5write(fileName,'/Data/Times', 0: dtframe : dtframe*(NCycles-1)  ); % ms → s 
    h5writeatt(fileName,'/Data/Times','unit', 's')

    %h5create(FileName,'/Data/Behavior', [Range,3]);
    %h5write(FileName,'/Data/Behavior', Behavior);

    h5create(fileName,'/Data/Values', [numberNeuron, NCycles]);
    h5write(fileName,'/Data/Values', calciumActivity);
    h5writeatt(fileName,'/Data/Values','type', 'DFF, single')

    h5create(fileName,'/Data/Stimulus', [1 , NCycles]);
    h5write(fileName,'/Data/Stimulus', Stimulus);

    % h5create(fileName, '/Data/ZBrainAtlas_Labels', [NCells, labels_size(2)]);
    % h5write(fileName, '/Data/ZBrainAtlas_Labels', Labels);

    clear calciumActivity

end