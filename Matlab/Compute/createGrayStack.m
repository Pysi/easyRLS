function createGrayStack(F, step)
%createGrayStack creates a gray stack (mean along t all 77 frames)

    if ~exist('step', 'var')
        step = 77;
    end

    m = Focused.Mmap(F, 'corrected');

    Focused.mkdir(F, 'graystack');
    outputInfo = [F.tag('graystack') '.toml'];
    
    writeINFO(outputInfo, m.x, m.y, m.z, 1, m.Z, m.space(1:3), 'uint16'); % make sure it's 3D

    mcorr = adapted4DMatrix(F, 'graystack', true); % create writable memory map

    for z = m.Z
        mcorr(:,:,z,1) = mean(m(:,:,z,1:step:m.t), 4);
    end
    
    % write nrrd header
    writeNHDR(F, 'graystack');
end
