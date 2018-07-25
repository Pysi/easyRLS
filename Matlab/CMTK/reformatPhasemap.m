function reformatPhasemap(F,trans_mode,max)
% use CMTK to reformat the imaginary and real part of phasemap

    % get path of reference brain
    refPath = F.get.refPath(F);
    regPath = F.get.regPath(F);

    % get graystack affine transformation to reference brain TODO set 'current transformation'
    transPath = F.get.transPath(F, trans_mode, 'graystack');
    [~, refo] = F.get.autoTransName(F, trans_mode, 'phasemap');

    prefix = 'pmpdff_';
    labels = {'realpart', 'imaginary'};

    for label = labels
        fulltag = [prefix label{:}]; 
        movPath = [F.tag(fulltag) '.nhdr']; % get floating stack
        outPathtag = fullfile(regPath, refo, label{:}); % directory
        outPath = [outPathtag '.nrrd']; % TODO to tag
        CMTK_reformat(refPath, movPath, outPath, transPath); % perform reformating
    end
    
    cd(fullfile(regPath, refo)); % go to folder
    file = dir('realpart.nrrd');
    
    [Ia,meta] = nrrdread(file.name);
    Ia = double(Ia);
    
    file = dir('imaginary.nrrd');
    Ib = double(nrrdread(file.name));
    
    % Save RGB images
    outdir = fullfile(regPath, refo,'PhaseMap_rgb'); % directory
    try
        mkdir(outdir)
    catch
        'Directory exist already'
    end
    v_max = max;
    clear imhsv
    dim = sscanf(meta.sizes, '%d');
   
    for l = 1: dim(3)
        l
        imhsv(:,:,1) =   mod(atan2(Ib(:,:,l),Ia(:,:,l)) , 2*pi) / (2*pi);
        imhsv(:,:,2) =   Ia(:,:,l,1)*0+1;
        imhsv(:,:,3) =   sqrt( Ia(:,:,l).^2 + Ib(:,:,l).^2 )/v_max;
        imwrite(hsv2rgb(imhsv),[outdir filesep 'layer' num2str(l,'%02d') '.tif']);
    end
    
end