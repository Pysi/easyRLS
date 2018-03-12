% /!\ be careful, this script might not be always up to date
% refer to the main script if there is a problem


%% quickscript
% this script does everything in one shot

start_time = tic;

% go in the project directory
cd /home/ljp/Science/Projects/easyRLS/
param.cwd = pwd;
% get focus
param.date = '2018-01-11';
param.run_number = 6;
param.Layers = 3:12; 
F = NT.Focus({param.cwd, '', param.date, param.run_number});
% create binary file from Tif
tifToMmap(F, {'z', param.Layers});
% compute drift on mmap
param.RefLayers = 8:10;
param.RefIndex = 10; 
driftCompute(F,{...
    'RefLayers', param.RefLayers, ...
    'RefIndex', param.RefIndex, ...
    'Layers', param.Layers, ...
    });
% applies drift
driftApply(F);
% define focus on reference stack and take its ROI if existing

Fref = NT.Focus({param.cwd, param.date, 5});
% create defMap
mapToReferenceBrain(F, Fref, param.RefIndex);
% finds ROI using reference brain mask
% use the mask predefined on the reference brain to find the mask for the
% current brain, saves autoROI as a mask.mat file
autoROI(F, Fref)
% load library to compute baseline
[~,~] = loadlibrary('/home/ljp/Science/Projects/easyRLS/Programs/easyRLS/Tools/caTools/caTools.so',...
                    '/home/ljp/Science/Projects/easyRLS/Programs/easyRLS/Tools/caTools/caTools.h');
% compute baseline using caTools library
caToolsRunquantile(F, param.Layers);
% compute gray stack
createGrayStack(F)
% compute background
background = 400;
% compute DFF
dff(F, param.Layers, background);

toc(start_time);