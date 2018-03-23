% /!\ be careful, this script might not be always up to date
% refer to the main script if there is a problem

%% before 
%load library to compute baseline
cd /home/ljp/Science/Projects/easyRLS/
[~,~] = loadlibrary('Programs/easyRLS/Tools/caTools/caTools.so',...
                    'Programs/easyRLS/Tools/caTools/caTools.h');

%% workflow preparation

% preliminary work : set ROI on raw RAS stack on each run you want to work on
cd /home/ljp/Science/Projects/RLS/
param.cwd = pwd;
param.date = '2018-03-19';
param.run = 2;
param.Layers = 3:20; 
param.RefLayers = 8:10;
param.RefIndex = 10; 
F = NT.Focus({param.cwd, '', param.date, param.run});
tifToMmap(F, {'z', param.Layers}); % raw.bin
Focused.transposeMmap(F, 'yxzrai', 'xyzras'); %rawRAS.bin

%%

% semi auto ROI
semiAutoROI(F, param.Layers, param.RefIndex, 'rawRAS'); % let you adjust automatic ROI


%% workflow 
% does everything in one shot so it can be run in a for or parfor loop

start_time = tic;

    driftCompute(F,{...
        'RefLayers', param.RefLayers, ...
        'RefIndex', param.RefIndex, ...
        'Layers', param.Layers, ...
        });
    driftApply(F);
    computeBackground(F, 'corrected', param.RefIndex);
    caToolsRunquantileLin(F, param.Layers)
    createGrayStack(F)
    dff(F, param.Layers);

disp('Time elapsed for [drift background baseline graystack dff] computation');
toc(start_time);


