function stackCoord(F, Layers)
% takes coords from specified layers and stack them in a single file
% /!\ for z computation, highest value of 'layers' must correspond to first layer in nrrd
% TODO record z somewhere, or ask the memory map on which registration has been done

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! take care to Z

    segPath = F.dir('Segmentation');
    
    coordinates = NaN(0,3);
    
    for z = Layers
%         F.select(z);
        inSeg = fullfile(segPath, [num2str(z, '%02d') '.mat']);
        load(inSeg, 'centerCoord', 'numberNeuron');
%         coordinates = [coordinates ; [centerCoord F.set.z*ones(numberNeuron, 1)]]; % concatenate
        % to find the z coordinate, we have to know where it is in the memory map
        zcoord = (Mmap.zCorrect(z, Layers) -1 ) * abs(F.param.Increment)/0.8;
        coordinates = [coordinates ; [centerCoord zcoord*ones(numberNeuron, 1)]]; % concatenate
    end
    
    numberNeuron = size(coordinates, 1);
    
    outCoord = fullfile(segPath, 'coordinates.mat');
    save(outCoord, 'coordinates', 'numberNeuron');
    
end