function createGrayStack(F)
%createGrayStack creates a gray stack (mean along t all 77 frames)

    m = Focused.Mmap(F, 'corrected');

    Focused.mkdir(F, 'graystack');
    outputInfo = [F.tag('graystack') '.toml'];
    
    writeINFO(outputInfo, m.x, m.y, length(F.Analysis.Layers), 1, m.Z, m.space, 'uint16');

    mcorr = adapted4DMatrix(F, 'graystack', true); % create writable memory map

    for z = m.Z
        mcorr(:,:,z,1) = mean(m(:,:,z,1:77:m.t), 4);
    end
end
