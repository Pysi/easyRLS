%% DEFAULT CONFIG : do not change

% if you want to set your config copy it in an other file (ex CONFIG_Hugo.m)
% and ignore it in the git

clear; clc

%% add programs
addPrograms('/home/ljp/Programs');

%% sample focus

root = '/home/ljp/Science/Projects/RLS/';
study = '';
date = '0000-00-00';
run = 0;

F = NT.Focus(root, study, date, run);

%% sample parameters

Analysis.Layers = 3:20;         % Layers to analyse
Analysis.RefLayers = 6:6;       % reference layers for drift correction
Analysis.RefIndex = 10;         % index of the reference stack for drift correction
Analysis.RefStack = '';         % external reference stack if exists

Analysis.BaselineWindow = 50;           % time in seconds of the baseline window
Analysis.DriftBox = [ 53 566 45 914 ];  % bounding box for drift correction
Analysis.Lineage = 'Cytoplasmic';       % possible values : 'Nuclear', 'Cytoplasmic'
Analysis.StimulusFrequency = 0.2;       % frequency of stimulus (Hz) for phasemap computation
% TODO correct the phasemap function to take into account other frequencies

F.Analysis = Analysis;

%% sample analysis

F = NT.Focus(root, study, '0000-00-00', 0);
F.Analysis = Analysis;
Fprepare(F);
Fanalyse(F, @workflowNeuron);
Fanalyse(F, @workflowPixel);

%% sample workflow

date = '2018-05-25'; % select date

RUNS = [ 3 4 7 8 11 12 15 ]; % select runs to prepare (adjust ROI)
prepare(root, study, date, Analysis, RUNS)

RUNS = [ 3 4 7 8 ]; % run cytoplasmic runs
Analysis.Lineage = 'cytoplasmic';
analyse(root, study, date, Analysis, RUNS, @workflowNeuron)

RUNS = [11 12 15]; % run nuclear runs
Analysis.Lineage = 'nuclear';
analyse(root, study, date, Analysis, RUNS, @workflowNeuron)

%% workflow function

% prepare several runs
function prepare(root, study, date, Analysis, RUNS) % manual part
    for run = RUNS
        F = NT.Focus(root, study, date, run);
        F.Analysis = Analysis;
        Fprepare(F);
    end
end

% prepare experiment given in focus
function Fprepare(F)
    semiAutoROI(F); 
end

% analyse several runs
function analyse(root, study, date, Analysis, RUNS, workflow) % automatic part
    for run = RUNS
        try
            F = NT.Focus(root, study, date, run);
            F.Analysis = Analysis;
            Fanalyse(F, workflow);
        catch me
            warning(me.identifier, '%s\nworking on next one', me.message);
        end
    end
end

% analyse experiment given in focus
function Fanalyse(F, workflow)
    workflow(F);
end

% workflow for per neuron analysis
function workflowNeuron(F)
    Focused.driftCompute(F);
    driftApply(F);
    computeBackground(F);
    createGrayStack(F)
    segmentBrain(F, 'graystack');
    computeBaselineNeuron(F);
    dffNeuron(F);
    phaseMapNeuron(F);
end

% workflow for per pixel analysis (workflowNeuron must have been runned first)
function workflowPixel(F)
    computeBaselinePixel(F);
    dffPixel(F);
    phaseMapPixel(F);
end