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
    load(fullfile(F.dir('Registration'), refBrainName, ['coordinates_' refBrainName '.mat']), 'refCoordinates');
    NCycles = F.param.NCycles;
    calciumActivity = [];
    
    % create delay vector
    n_layers = 18; % ground truth!
    delays_z = (0:0.02:0.34) + 0.04;  % delays for layers 3 - 20
     unique_z_coordinates = sort(unique(coordinates(:, 3)), 'descend');  % find unique z coordinates max to min
    if length(unique_z_coordinates) == n_layers % assert if length(unique z coordinates) == 18
        n_cells = size(coordinates, 1)
        delays_neurons = zeros(n_cells, 1);
        for i_z = 1:n_layers % it will go from max z to min z, which corresponds to min t delayto max t delay
            current_neurons = find(coordinates(:, 3) == unique_z_coordinates(i_z));
            delays_neurons(current_neurons) = delays_z(i_z);  % match z coordinates with delays_z
        end
    end
        
        

    % === concatenate neurons activity
    for iz = F.Analysis.Layers % Layers should be sorted (ex 3 4 5 ... 19 20)
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
    h5create(fileName,'/Data/Coordinates', [numberNeuron 3], 'Datatype', 'single'); % xyz = 3 coordinates
    h5write(fileName,'/Data/Coordinates', single(coordinates ./ 1000)); % µm → mm
    h5writeatt(fileName,'/Data/Coordinates','unit', 'mm')
    h5writeatt(fileName,'/Data/Coordinates','orientation', 'RAS')
    
    h5create(fileName,'/Data/TimeDelays',[n_cells, 1], 'Datatype', 'single');
    h5write(fileName,'/Data/TimeDelays', single(delays_neurons));
    
%     h5create(fileName,'/Data/PM_Phase',[n_cells, 1], 'Datatype', 'single');
%     h5write(fileName,'/Data/PM_Phase', phase_array);
%     
%     h5create(fileName,'/Data/PM_Amplitude',[n_cells, 1], 'Datatype', 'single');
%     h5write(fileName,'/Data/PM_Amplitude', amplitude_array);
    
    h5create(fileName,'/Data/RefCoordinates', [numberNeuron 3], 'Datatype', 'single');
    h5write(fileName, '/Data/RefCoordinates', single(refCoordinates ./ 1000));
    h5writeatt(fileName,'/Data/RefCoordinates','unit', 'mm')
    h5writeatt(fileName,'/Data/RefCoordinates','orientation', 'RAS')

    h5create(fileName,'/Data/Times', [1 NCycles], 'Datatype', 'single');
    dtframe = F.dt / 1000 * F.param.NLayers ;
    h5write(fileName,'/Data/Times', single(0: dtframe : dtframe*(NCycles-1))  ); % ms → s 
    h5writeatt(fileName,'/Data/Times','unit', 's')

    %h5create(FileName,'/Data/Behavior', [Range,3]);
    %h5write(FileName,'/Data/Behavior', Behavior);

    h5create(fileName,'/Data/Values', [numberNeuron, NCycles], 'Datatype', 'single');
    h5write(fileName,'/Data/Values', single(calciumActivity));
    h5writeatt(fileName,'/Data/Values','type', 'DFF, single')

    h5create(fileName,'/Data/Stimulus', [1 , NCycles], 'Datatype', 'single');
    h5write(fileName,'/Data/Stimulus', single(Stimulus));

    % return label from zbrain coordinate space for RAS data
    labels = addLabels(refCoordinates ./ 1000);
    
    h5create(fileName,'/Data/Labels', size(labels), 'Datatype', 'single');
    h5write(fileName,'/Data/Labels', single(labels));
    % h5create(fileName, '/Data/ZBrainAtlas_Labels', [NCells, labels_size(2)]);
    % h5write(fileName, '/Data/ZBrainAtlas_Labels', Labels);

    clear calciumActivity

end