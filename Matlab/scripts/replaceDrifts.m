% replaceDrifts script

N = F.param.NCycles; % number of images for a layer
delta = 1/F.param.NLayers; % deltaphi between images

% load backup drift
load(fullfile(F.dir('Drift'), 'Drifts_.mat'), 'dx', 'dy');

% define parameters
Ay = 1.873;
Aphi = 1.115;
RefLayer = 6;
sinusStim = @(A,t,phi) A * sin( 119.92 * 2*pi * (t-1)/N -3*pi/4 * phi);

% replace all dy values 
for i = 1:20    
    delta_i = delta*(i-RefLayer); % delta phi for interpolation
    dy_forRefLayer = sinusStim(Ay, 1:N, Aphi);
    dy(i,:) = imtranslate(dy_forRefLayer, [-delta_i, 0]); % applies the interpolation for each layer
end

save(fullfile(F.dir('Drift'), 'Drifts.mat'), 'dx', 'dy');