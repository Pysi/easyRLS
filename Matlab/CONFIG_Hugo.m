%% CONFIG

clear; clc

root = '/home/ljp/Science/Projects/RLS1P/';
study = '';
date = '2018-05-21';
run = 3;

cd(root)
addpath(genpath('easyRLS/Matlab'))
addpath(genpath('NeuroTools/Matlab'))

F = NT.Focus(root, study, date, run);

Analysis.Layers = 3:20;
Analysis.RefLayers = 6:6;
Analysis.RefIndex = 10;
Analysis.RefStack = '';

F.Analysis = Analysis;

%% load library to compute baseline

cd(F.dir('caTools'))
[~,~] = loadlibrary('caTools.so',...
                    'caTools.h');

%% workflow

RUNS = [4 6 8];

%%% manual part
for run = RUNS
    F = NT.Focus(root, study, date, run);
    F.Analysis = Analysis;
    semiAutoROI(F, 'dcimg.dcimg');
end

%%% automatic part
for run = RUNS
    % init focus
    F = NT.Focus(root, study, date, run);
    F.Analysis = Analysis;
    
    % do stuff
    Focused.driftCompute(F, 'dcimg.dcimg');
    driftApply(F, 'dcimg.dcimg');
    computeBackground(F, 'corrected');
    createGrayStack(F)
    segmentBrain(F, 'graystack');
    computeBaselineNeuron(F, 50);
    computeBaselinePixel(F, 3:20, 50);
    dffNeuron(F);
    dffPixel(F, 3:20);
    phaseMapPixel(F, 0.2)
    phaseMapNeuron(F, 0.2)
end

F = NT.Focus(root, study, date, 4);
F.Analysis = Analysis;

function workflow(F)
    Focused.driftCompute(F, 'dcimg.dcimg');
    driftApply(F, 'dcimg.dcimg');
    computeBackground(F, 'corrected');
    createGrayStack(F)
    segmentBrain(F, 'graystack');
    computeBaselineNeuron(F, 50);
%     computeBaselinePixel(F, 3:20, 50);
    dffNeuron(F);
%     dffPixel(F, 3:20);
%     phaseMapPixel(F, 0.2)
    phaseMapNeuron(F, 0.2)
end

%%
path.RefBrains = '/home/ljp/Science/RefBrains';