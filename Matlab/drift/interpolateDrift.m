% interpolate drift

N = F.param.NCycles; % number of images for a layer
delta = 1/F.param.NLayers; % deltaphi between images

% load backup drift
load(fullfile(F.dir('Drift'), 'Drifts_.mat'), 'dx', 'dy');

% choose a layer well corrected
reflayer = 7;
LayersToReplace = 1:20;

corrX = dx(reflayer,:);
corrY = dy(reflayer,:);

% replace drift by interpolated versions
for i = LayersToReplace   
    delta_i = delta*(i-reflayer);
    dx(i,:) = imtranslate(corrX, [-delta_i, 0]);
    dy(i,:) = imtranslate(corrY, [-delta_i, 0]);
end

% save new drift
save(fullfile(F.dir('Drift'), 'Drifts.mat'), 'dx', 'dy');
