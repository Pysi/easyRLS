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
% TODO add refbrain here and to focus
Analysis.Lineage = 'nuclear';
F.Analysis = Analysis;

%% load library to compute baseline

cd(F.dir('caTools'))
[~,~] = loadlibrary('caTools.so',...
                    'caTools.h');

%% workflow

date = '2018-05-21';
RUNS = [ 3 4 6 8 ];
prepare(root, study, date, Analysis, RUNS)
analyse(root, study, date, Analysis, RUNS, @workflowPixel)

%%
F = NT.Focus(root, study, '2018-05-25', 12);
F.Analysis = Analysis;
stackViewer2D(F, 'DFFNeuron');
%%
Focused.phaseMapViewer(F, 'neuron')

%%
date = '2018-05-25';

% RUNS = [ 3 4 7 8 11 12 15 ]; 
% prepare(root, study, date, Analysis, RUNS)

TTT = tic;

RUNS = [ 3 4 7 8 ]; 
Analysis.Lineage = 'cytoplasmic';
analyse(root, study, date, Analysis, RUNS, @workflowNeuron)

RUNS = [11 12 15];
Analysis.Lineage = 'nuclear';
analyse(root, study, date, Analysis, RUNS, @workflowNeuron)

TIME = toc(TTT);
disp(TIME);

function prepare(root, study, date, Analysis, RUNS) % manual part
    for run = RUNS
        F = NT.Focus(root, study, date, run);
        F.Analysis = Analysis;
        semiAutoROI(F, 'dcimg.dcimg'); 
    end
end

function analyse(root, study, date, Analysis, RUNS, workflow) % automatic part
    for run = RUNS
        try
            F = NT.Focus(root, study, date, run);
            F.Analysis = Analysis;
            workflow(F)
        catch me
            warning(me.identifier, '%s\nworking on next one', me.message);
        end
    end
end

function workflowNeuron(F)
    Focused.driftCompute(F, 'dcimg.dcimg');
    driftApply(F, 'dcimg.dcimg');
    computeBackground(F, 'corrected');
    createGrayStack(F)
    segmentBrain(F, 'graystack');
    computeBaselineNeuron(F, 50);
    dffNeuron(F);
    phaseMapNeuron(F, 0.2)
end

function workflowPixel(F) % workflowNeuron must have been runned first
    computeBaselinePixel(F, 3:20, 50);
    dffPixel(F, 3:20);
    phaseMapPixel(F, 0.2)
end
