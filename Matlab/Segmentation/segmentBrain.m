function segmentBrain(F, tag)
%segmentBrain segments the brain layer by layer using segmentNeuron

    m = Focused.Mmap(F, tag); % get gray stack
    load(F.tag('mask'), 'mask'); % get mask

    segPath = F.dir('Segmentation');
    Focused.mkdir(F, 'Segmentation');
    
    % for nuclear lineage
    switch lower(F.Analysis.Lineage)
        case 'nuclear'
            nuc = true;
        case 'cytoplasmic'
            nuc = false;
        otherwise
            error('lineage unknowned : %s', F.Analysis.Lineage);
    end

    for z = m.Z % for each layer
        Img = m(:,:,z,1);
        Mask = mask(:,:,z);

        [centerCoord, neuronShape, CD] = segmentNeuron(Img, Mask, nuc);  %#ok<ASGLU>
        numberNeuron = length(centerCoord);                     %#ok<NASGU>
        outSeg = fullfile(segPath, [num2str(z, '%02d') '.mat']);
        outIMG = fullfile(segPath, [num2str(z, '%02d') '.png']);
        save(outSeg, 'centerCoord', 'neuronShape', 'numberNeuron');
        imwrite(CD, outIMG);
    end
    
    stackCoord(F); % gets all the coordinates and convert them to micrometers

end