% /!\ be careful, this script might not be always up to date
% refer to the main script if there is a problem

%% before 
%load library to compute baseline
cd /home/ljp/Science/Projects/easyRLS/
[~,~] = loadlibrary('Programs/easyRLS/Tools/caTools/caTools.so',...
                    'Programs/easyRLS/Tools/caTools/caTools.h');

%% workflow preparation

% preliminary work : set ROI on raw RAS stack on each run you want to work on
cd /home/ljp/Science/Projects/easyRLS/
param.cwd = pwd;
param.date = '2018-01-11';
param.run = 'Run05';
param.Layers = 3:12; 
param.RefLayers = 8:10;
param.RefIndex = 10; 
F = NT.Focus({param.cwd, '', param.date, param.run});
tifToMmap(F, {'z', param.Layers});
Focused.transposeMmap(F, 'yxzrai', 'xyzras');

% semi auto ROI
semiAutoROI(F, param.Layers, param.RefIndex); % let you adjust automatic ROI


%% workflow 
% does everything in one shot so it can be run in a for or parfor loop

start_time = tic;

    driftCompute(F,{...
        'RefLayers', param.RefLayers, ...
        'RefIndex', param.RefIndex, ...
        'Layers', param.Layers, ...
        });
    driftApply(F);
    caToolsRunquantileLin(F, param.Layers)
    createGrayStack(F)
    param.background = 400;
    dff(F, param.Layers, param.background);

toc(start_time);


