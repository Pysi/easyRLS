%% CONFIG

clear; clc

cd /home/ljp/Programs/
addpath(genpath('easyRLS/Matlab'))
addpath(genpath('NeuroTools/Matlab'))

root = '/home/ljp/Science/Projects/RLS/';
study = '';
date = '2018-05-21';
run = 0;

F = NT.Focus(root, study, date, run);

F.Analysis.Layers = 3:20;
F.Analysis.RefLayers = 6:6;
F.Analysis.RefIndex = 10;
F.Analysis.RefStack = '';


%% load library to compute baseline

cd(F.dir('caTools'))
[~,~] = loadlibrary('caTools.so',...
                    'caTools.h');

%% workflow

Focused.driftCompute(F, 'dcimg.dcimg');
driftApply(F, 'dcimg.dcimg');
computeBackground(F, 'corrected');
createGrayStack(F)
segmentBrain(F, 'graystack');
computeBaselineNeuron(F, 50);
computeBaselinePixel(F, 20:3, 50);
dffNeuron(F);
dffPixel(F, 20:3);
phaseMapPixel(F, 0.2)
phaseMapNeuron(F, 0.2)



%%
path.RefBrains = '/home/ljp/Science/RefBrains';