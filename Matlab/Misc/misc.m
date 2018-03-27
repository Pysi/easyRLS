% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

%% shortcut: Tif to RAS
%{
tifToRAS(F, param.Layers);
%% view hyperstack
Focused.stackViewer(F, 'rawRAS');
%% compute drift on mmap
driftCompute(F,{...
    'RefLayers', param.RefLayers, ...
    'RefIndex', param.RefIndex, ...
    'Layers', param.Layers, ...
    });
%% see if drift is well corrected
seeDriftCorrection(F); % plays a movie
%% applies drift if it is ok
driftApply(F);
%% view corrected hyperstack
%}

%% do imregdemons on an other similar brain with a mask
%{
Fref = NT.Focus(param.wd, '', param.date, 6);
% create defMap (deformation map)
mapToReferenceBrain(F, Fref, param.RefIndex);
% finds ROI using reference brain mask
% use the mask predefined on the reference brain to find the mask for the
% current brain, saves autoROI as a mask.mat file
autoROI(F, Fref)
Focused.stackViewer(F, 'ROImask');
%}

%% benchmark
%{
global LOADING
global COMPUTING
global WRITING
caToolsRunquantileLin_BENCHMARK(F, 3)
figure; hold on;
plot(LOADING)
plot(COMPUTING)
plot(WRITING)
legend('LOADING', 'COMPUTING', 'WRITING');
title('uint16')
%}

%% manual section

%{
% % % % % % TIF
% create binary file from Tif
tifToMmap(F, {'z', param.Layers});
% % % % % % DCIMG
% create binary from dcimg
Focused.dcimgToMmap(F, tag, kwargs)
% % % % % % RAS
% transpose to RAS
Focused.transposeMmap(F, 'yxzrai', 'xyzras'); % TODO know automatically from parameters
%}

%{
% view manually
m = Focused.Mmap(F, 'corrected');   % builds memory map
imshow(m(:,:,3,10),[300 1000]);      % diplays x, y, z, t
%}
