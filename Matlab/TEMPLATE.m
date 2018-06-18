%% TEMPLATE : do not change this file !!!

% if you want to change this file
% create instead a copy in other file (ex TEMPLATE_Hugo.m)
% and ignore it in the git if you only want it locally

% if you change this file, make sure you discard your changes before commiting

clear; clc

%% add programs
addPrograms('/home/ljp/');
root = '/home/ljp/'
%% sample focus

root = '/home/ljp/Science/Projects/RLS/';
study = '';
date = '2018-05-24';
run = 25;

F = NT.Focus(root, study, date, run);

% sample parameters

Analysis.Layers = 6:20;         % Layers to analyse
Analysis.RefLayers = 8:10;       % reference layers for drift correction
Analysis.RefIndex = 10;         % index of the reference frame for drift correction
Analysis.RefStack = '';         % external reference stack if exists

Analysis.BaselineWindow = 50;           % time in seconds of the baseline window
Analysis.BaselinePercentile = 10;       % percentile for baseline computation
Analysis.DriftBox = [ 53 555 45 888 ];  % bounding box for drift correction
Analysis.Lineage = 'Cytoplasmic';       % possible values : 'Nuclear', 'Cytoplasmic'
Analysis.StimulusFrequency = 0.2;       % frequency of stimulus (Hz) for phasemap computation
Analysis.Stimulus = 'sinus';            % type of stimulus (step/sinus)
Analysis.Overwrite = false;             % defines if it has tpo be overwritten
% TODO correct the phasemap function to take into account other frequencies

Analysis.RefBrain = 'zBrain_Elavl3-H2BRFP_RAS.nhdr'; % choose refbrain to map onto

% loads the parameters in the current focus
F.Analysis = Analysis;

%% quick focus

F = NT.Focus(root, study, '2018-05-29', 7, Analysis);         % define focus

%% sample functions (to run the analysis function by function)

% --- manual part
semiAutoROI(F); 
% --- preparatory stuff
Focused.driftCompute(F);
driftApply(F);
computeBackground(F);
createGrayStack(F)
segmentBrain(F, 'graystack');
% --- per neuron
computeBaseline(F, 'neuron');
computeDFF(F, 'neuron');
computePhaseMap(F, 'neuron');
% --- per pixel
computeBaseline(F, 'pixel');
computeDFF(F, 'pixel');
computePhaseMap(F, 'pixel', 'signal');
% --- export
mapToRefBrain(F, 'affine', '', 'graystack');
mapToRefBrain(F, 'convertcoord', 'affine', 'graystack');
exportToHDF5(F);

%% sample viewer (collection of all viewer functions)

Focused.stackViewer(F, 'source');
Focused.stackViewer(F, 'ROImask');
seeDriftCorrection(F);
Focused.stackViewer(F, 'corrected');
Focused.stackViewer(F, 'graystack')
stackViewer2D(F, 'BaselineNeuron');
stackViewer2D(F, 'DFFNeuron');
Focused.phaseMapViewer(F, 'signal pixel')

%% sample workflow (prepare runs)

date = '2018-06-07'; % select date

RUNS = [ 3 ]; % select runs to prepare (adjust ROI)
prepare(root, study, date, Analysis, RUNS) % run the loop

%% sample workflow (launch analysis)
clearvars -except Analysis root study 

date = '2018-06-07'; % select date
RUNS = [ 3 ]; % select a set of runs 
%RUNS = [ 11]; % select a set of runs 

Analysis.Lineage = 'Cytoplasmic'; % overwrite parameters
Analysis.Stimulus = 'sinus'; % overwrite parameters

TTT=tic;
%analyse(root, study, date, Analysis, RUNS, @workflowNeuron) % run per neuron analysis
analyse(root, study, date, Analysis, RUNS, @workflowPixel) % run per pixel analysis
%analyse(root, study, date, Analysis, RUNS, @workflowChangeSpace) % run per pixel analysis
%analyse(root, study, date, Analysis, RUNS, @workflowRevertMask) % run per pixel analysis

TIME=toc(TTT);
fprintf('total time for date %s and runs %s : %d\n', date, num2str(RUNS), TIME)


%% workflow functions

% prepare several runs
function prepare(root, study, date, Analysis, RUNS) % manual part
    for run = RUNS
        F = NT.Focus(root, study, date, run);
        fprintf("Preparing %s\n", F.name);
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
            fprintf("Analysing %s\n", F.name);
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
    switch F.Analysis.Stimulus
        case 'sinus'
            phaseMapNeuron(F);
    end
end

% workflow for per pixel analysis (workflowNeuron must have been runned first)
function workflowPixel(F)
    Focused.driftCompute(F);
    driftApply(F);
    computeBackground(F);
    createGrayStack(F)

    computeBaselinePixel(F);
    computeDFF(F, 'pixel');
%     switch F.Analysis.Stimulus
%         case 'sinus'
%             phaseMapPixel(F);
%     end
end


% workflow for space direction correction
function workflowChangeSpace(F)
  changeSpace(F, 'corrected', 'LAST') 
end

% workflow revertMask
function workflowRevertMask(F)
  revertMask(F,'LAST','RAST');
end

%% adding programs

function addPrograms(root)
%addPrograms adds the matlab programs to the path and loads the caTools library
% root is the root of the programs (ex /home/ljp/programs)

    % adds matlab programs path
    addpath(genpath(fullfile(root,'Programs', 'easyRLS','Matlab')));
    addpath(genpath(fullfile(root,'Programs', 'NeuroTools','Matlab')));

    dir = NT.Focus.architecture(root, 'none');

    if ismac
        warning('test if caTools is ok for mac');
    elseif isunix
        cd(dir('caTools'))
        [~,~] = loadlibrary('caTools.so',...
                            'caTools.h');
    elseif ispc
        cd(dir('caTools'))
        [~,~] = loadlibrary('caTools.dll',...
                            'caTools.h');
    else
        disp('Platform not supported')
    end
    disp('done');
end