function mapToReferenceBrain(F, Fref, RefIndex)
%mapToReferenceBrain saves the deformation field to the reference brain

    m = Focused.Mmap(F, 'corrected');
    mref = Focused.Mmap(Fref, 'corrected');

    % x and y deformation map for each layer
    defMap=zeros(m.x, m.y, 2, 20);

    w = waitbar(0, 'Mapping to reference brain');

    for z = m.Z
        [defMap(:,:,:,z),~] = ...
            imregdemons(m(:,:,z,RefIndex),...
            mref(:,:,z,RefIndex), [8,4,2],...
            'PyramidLevels', 3, 'DisplayWaitbar', false);
        waitbar(z/m.z) 
    end

    close(w)

    [~,~] = mkdir(F.dir('Garbage'));
    defMapPath = fullfile(F.dir('Garbage'), 'defMap.mat');
    save(defMapPath, 'defMap');

end