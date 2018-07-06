function reformatPhasemap(F)
% use CMTK to reformat the imaginary and real part of phasemap

    % get path of reference brain
    refPath = F.get.refPath(F);
    regPath = F.get.regPath(F);

    % get graystack affine transformation to reference brain TODO set 'current transformation'
    transPath = F.get.transPath(F, 'warp', 'graystack');
    [~, refo] = F.get.autoTransName(F, 'warp', 'phasemap');

    prefix = 'pmpdff_';
    labels = {'realpart', 'imaginary'};

    for label = labels
        fulltag = [prefix label{:}]; 
        movPath = [F.tag(fulltag) '.nhdr']; % get floating stack
        outPathtag = fullfile(regPath, refo, label{:}); % directory
        outPath = [outPathtag '.nrrd']; % TODO to tag
        CMTK_reformat(refPath, movPath, outPath, transPath); % perform reformating
    end

end