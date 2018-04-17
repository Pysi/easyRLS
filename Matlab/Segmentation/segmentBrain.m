function segmentBrain(F, tag, Layers)
%segmentBrain segments the brain layer by layer using segmentNeuron

    m = Focused.Mmap(F, tag); % get gray stack
    load(fullfile(F.dir.IP, 'mask.mat'), 'mask'); % get mask

    segPath = fullfile(F.dir.IP, 'Segmented');
    disp('creating ''Segmented'' directory'); mkdir(segPath);

    for z = Layers % for each layer
        Img = m(:,:,z,1);
        Mask = mask(:,:,z);

        [centerCoord, neuronShape] = segmentNeuron(Img, Mask);  %#ok<ASGLU>
        numberNeuron = length(centerCoord);                     %#ok<NASGU>
        outSeg = fullfile(segPath, [num2str(z, '%02d') '.mat']);
        save(outSeg, 'centerCoord', 'neuronShape', 'numberNeuron');

    end

end