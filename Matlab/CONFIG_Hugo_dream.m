%% CONFIG

%% load dependencies

% add programs
cd /home/ljp/Programs/
addpath(genpath('easyRLS/Matlab'))
addpath(genpath('NeuroTools/Matlab'))

% load library to compute baseline
cd(F.dir('caTools'))
[~,~] = loadlibrary('caTools.so',...
                    'caTools.h');

                
%% define focus
clear; clc;

root    = '/home/ljp/Science/Projects/RLS/';
study   = '';
date    = '2018-05-21';
run     = 0;

F = NT.Focus(root, study, date, run);

Analysis.Layers = 3:20;         % Layers to analyse
Analysis.RefLayers = 6:6;       % reference layers for drift correction
Analysis.RefIndex = 10;         % index of the reference stack for drift correction
Analysis.RefStack = '';         % external reference stack if exists

Analysis.BaselineWindow = 50;   % time in seconds of the baseline window
Analysis.DriftBox = [ 53 566 45 914 ]; % bounding box for drift correction
Analysis.Lineage = 'Cytoplasmic'; % possible values : 'Nuclear', 'Cytoplasmic'
Analysis.StimulusFrequency = 0.2; % frequency of stimulus (Hz) for phasemap computation

F.Analysis = Analysis;



%% workflow

% path.RefBrains = '/home/ljp/Science/RefBrains';

% RUNS = [4 6 8];
% 
% %%% manual part
% for run = RUNS
%     F = NT.Focus(root, study, date, run);
%     F.Analysis = Analysis;
%     semiAutoROI(F, 'dcimg.dcimg');
% end
% 
% %%% automatic part
% for run = RUNS
%     % init focus
%     F = NT.Focus(root, study, date, run);
%     F.Analysis = Analysis;
%     
%     % do stuff
%     Focused.driftCompute(F, 'dcimg.dcimg');
%     driftApply(F, 'dcimg.dcimg');
%     computeBackground(F, 'corrected');
%     createGrayStack(F)
%     segmentBrain(F, 'graystack');
%     computeBaselineNeuron(F, 50);
%     computeBaselinePixel(F, 3:20, 50);
%     dffNeuron(F);
%     dffPixel(F, 3:20);
%     phaseMapPixel(F, 0.2)
%     phaseMapNeuron(F, 0.2)
% end

F = NT.Focus(root, study, date, 4);
F.Analysis = Analysis;
workflow(F);

function workflow(F)
    Focused.driftCompute(F, 'dcimg.dcimg');
    driftApply(F, 'dcimg.dcimg');
    computeBackground(F, 'corrected');
    createGrayStack(F)
    segmentBrain(F, 'graystack');
    computeBaselineNeuron(F);
    computeBaselinePixel(F);
    dffNeuron(F);
    dffPixel(F);
    phaseMapPixel(F)
    phaseMapNeuron(F)
end


