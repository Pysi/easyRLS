function zBrainLabelsOnPhaseMap(F,all,Avg,trans_mode)
%% Path
load(fullfile(F.dir('Root'),'Tools/zBrain/MaskDatabase.mat'));
switch Avg
    case 'Avg'
        stack_path = fullfile(F.dir('AveragedPhaseMaps'),'stack');
        out_path = fullfile(F.dir('AveragedPhaseMaps'),'stack_brain_region');
    otherwise
        regPath = F.get.regPath(F);
        [~, refo] = F.get.autoTransName(F, trans_mode, 'phasemap');
        stack_path = fullfile(regPath, refo,'PhaseMap_rgb');
        out_path = fullfile(regPath, refo,'PhaseMap_rgb_Labeled');
        try
            mkdir(out_path)
        catch
            'Warning: Directory already exists'
        end
end
grey_stack_path = fullfile(F.dir('RefBrains'),F.Analysis.RefBrain);

brain_regions = {'Diencephalon -' 'Diencephalon - Habenula' 'Mesencephalon - Torus Longitudinalis' 'Rhombencephalon - Cerebellum' 'Rhombencephalon - Inferior Olive' 'Rhombencephalon - Oculomotor Nucleus nIV' 'Rhombencephalon - Spinal Backfill Vestibular Population' 'Rhombencephalon - Tangential Vestibular Nucleus' 'Rhombencephalon - Valvula Cerebelli' 'Ganglia - Eyes' 'Mesencephalon - NucMLF (nucleus of the medial longitudinal fascicle)' 'Mesencephalon - Oculomotor Nucleus nIII', 'Mesencephalon - Tectum Stratum Periventriculare', 'Mesencephalon - Tegmentum', 'Ganglia - Statoacoustic Ganglion'};

if ~all
%% Add the brain regions selected
    for layer = 1:Zs
        layer
        % Create an RGB image of the brain regions selected
        img_br = zeros(height, width);
        for br = 1:size(brain_regions, 2)
            brain_region = find(ismember(MaskDatabaseNames,brain_regions{br}));
            MaskDatabaseNames(brain_region);
            img_brain_region = MaskDatabaseOutlines(height*width*(layer-1)+1:height*width*(layer),brain_region);
            img_brain_region = reshape(img_brain_region, [height, width]);
            img_brain_region = full(img_brain_region);
            img_br(img_brain_region == 1) = 1;
    %         imshow(img_br);
    %         pause(0.05)
        end
        % Add the brain regions selected to the stack
        img = imread([stack_path, '/layer', num2str(layer, '%02d'), '.tif']);
        img_brain_region_RGB = cat(3, img_br, img_br, img_br);
        img = imrotate(img, 180);
        img(img_brain_region_RGB == 1) = inf;
        img_grey = img(:,:,1)*0;
       % img_grey = imread([grey_stack_path, num2str((layer-1), '%04d'), '.tif']);
        img_grey = cat(3, img_grey, img_grey, img_grey);
        img_grey = img + uint8(img_grey/(300));
        imwrite(img_grey, [out_path, '/layer', num2str(layer, '%02d'), '.tif']);
    end

    else
    %% All the brain regions
    for layer = 1:Zs
        layer
        % Create an RGB image of the brain regions
        img_br = zeros(height, width);
        for br = 1:294
            brain_region = br;
            MaskDatabaseNames(brain_region);
            img_brain_region = MaskDatabaseOutlines(height*width*(layer-1)+1:height*width*(layer),brain_region);
            img_brain_region = reshape(img_brain_region, [height, width]);
            img_brain_region = full(img_brain_region);
            img_br(img_brain_region == 1) = 1;
        end
        % Add the brain regions
        img = imread([stack_path, '/layer', num2str(layer, '%02d'), '.tif']);
        img_brain_region_RGB = cat(3, img_br, img_br, img_br);
        img = imrotate(img, 180);
        img(img_brain_region_RGB == 1) = inf;
        img_grey = img(:,:,1)*0;
        % img_grey = imread([grey_stack_path, num2str((layer-1), '%04d'), '.tif']);
        img_grey = cat(3, img_grey, img_grey, img_grey);
        img_grey = img + uint8(img_grey/(300));
        imwrite(img_grey, [out_path, '/layer', num2str(layer, '%02d'), '.tif']);
    end

end

end