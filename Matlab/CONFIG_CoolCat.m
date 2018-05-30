%% CONFIG

clear; clc

cd /home/ljp/Programs/
addpath(genpath('easyRLS/Matlab'))
addpath(genpath('NeuroTools/Matlab'))

root = '/home/ljp/Science/Projects/RLS/';
study = '';
date = '2018-05-24';
run = 8;

F = NT.Focus(root, study, date, run);

Analysis.Layers = 3:20;
Analysis.RefLayers = 3:3;
Analysis.RefIndex = 10;
Analysis.RefStack = '';
Analysis.Lineage = 'nuclear';

F.Analysis = Analysis;

%% load library to compute baseline

cd(F.dir('caTools'))
[~,~] = loadlibrary('caTools.so',...
                    'caTools.h');

%% workflow

TTTTT = tic;

F = NT.Focus(root, study, '2018-05-24', 3);
F.Analysis = Analysis;
computeBaselineNeuron(F, 50);
dffNeuron(F);
phaseMapNeuron(F, 0.2)

F = NT.Focus(root, study, '2018-05-24', 8);
F.Analysis = Analysis;
Focused.driftCompute(F, 'dcimg.dcimg');
driftApply(F, 'dcimg.dcimg');
computeBackground(F, 'corrected');
createGrayStack(F)
segmentBrain(F, 'graystack');
computeBaselineNeuron(F, 50);
dffNeuron(F);
phaseMapNeuron(F, 1/80)

time = toc(TTTTT);

disp(time);
disp('the computer was over sollicited');

%%
path.RefBrains = '/home/ljp/Science/RefBrains';