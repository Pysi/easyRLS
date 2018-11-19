%% TEMPLATE : do not change this file !!!

% if you want to change this file
% create instead a copy in other file (ex TEMPLATE_Hugo.m)
% and ignore it in the git if you only want it locally

% if you change this file, make sure you discard your changes before commiting

clear; clc

%% add programs
addPrograms('/home/ljp/');
%addPrograms('/media/RED/ljp');
% root = '/home/ljp/'
%% sample focus

% root = '/home/ljp/Science/Hugo/RLS1P/';
% root = '/home/ljp/Science/Hugo/RLS2P/';
root = '/home/ljp/SSD/';
% root = '/home/ljp/Science/Projects/RLS/';
% root = '/media/RED/Science/Projects/RLS1P/';
study = '';
date = '2018-11-08';
run = 3;

F = NT.Focus(root, study, date, run);

% sample parameters

clear Analysis

Analysis.Layers = 2:8;         % Layers to analyse
% Analysis.RefLayers = 8:10;       % reference layers for drift correction
Analysis.RefIndex = 1;         % index of the reference frame for drift correction
Analysis.RefStack = '';         % external reference stack if exists
Analysis.BaselineWindow = 50;           % time in seconds of the baseline window
Analysis.BaselinePercentile = 10;       % percentile for baseline computation
Analysis.DriftBox = [ 1 730 1 1024 ];  % bounding box for drift correction
Analysis.Lineage = 'Nuclear';           % possible values : 'Nuclear', 'Cytoplasmic'
Analysis.StimulusFrequency = 0.2;       % frequency of stimulus (Hz) for phasemap computation
Analysis.Stimulus = 'sinus';            % type of stimulus (step/sinus)
Analysis.Overwrite = false;              % defines if it has tpo be overwritten
% TODO correct the phasemap function to take into account other frequencies

Analysis.RefBrain = 'zBrain_Elavl3-H2BRFP_198layers.nhdr'; % choose refbrain to map onto

% loads the parameters in the current focus
F.Analysis = Analysis;

%% quick focus

F = NT.Focus(root, study, '2018-10-24', 4); % static 1P     
F = NT.Focus(root, study, '2018-10-24', 5); % rot 1P
F = NT.Focus(root, study, '2018-10-24', 6); % rot 2P
F = NT.Focus(root, study, '2018-10-24', 7); % static 2P

%% sample viewer (collection of all viewer functions)

Focused.stackViewer(F, 'source');
Focused.stackViewer(F, 'ROImask');
seeDriftCorrection(F);
Focused.stackViewer(F, 'corrected', [400 800]);
Focused.stackViewer(F, 'graystack');
stackViewer2D(F, 'BaselineNeuron');
stackViewer2D(F, 'DFFNeuron');
stackViewer2D(F, 'BaselinePixel');
stackViewer2D(F, 'DFFPixel');
Focused.phaseMapViewer(F, 'signal pixel');
Focused.phaseMapViewer(F, 'dff pixel',10);
Focused.phaseMapViewer(F, 'dff neuron');

%% sample functions (to run the analysis function by function)

% --- manual part
semiAutoROI(F); 
% --- preparatory stuff
Focused.driftCompute(F, 'both')
    driftApply(F);
driftComputeAndApply(F, 'on') % calculates the drift for every layer independently
% ---
computeBackground(F);
createGrayStack(F);%500
segmentBrain(F, 'graystack','RC');
% --- per neuron
computeBaseline(F, 'neuron');
computeDFF(F, 'neuron');
computePhaseMap(F, 'neuron');
% --- per pixel
computeBaseline(F, 'pixel');
computeDFF(F, 'pixel');
computePhaseMap(F, 'pixel', 'signal');
computePhaseMap(F, 'pixel', 'dff');
% --- export
mapToRefBrain(F, 'affine', '', 'graystack');
mapToRefBrain(F, 'convertcoord', 'affine', 'graystack');
exportToHDF5(F);

% --- reformat phasemap

%% sample workflow (prepare runs)

date = '2018-06-14'; % select date
RUNS = [ 12 ]; % select runs to prepare (adjust ROI)
prepare(root, study, date, Analysis, RUNS) % run the loop

%% === sample workflow (launch analysis)

clearvars -except Analysis root study 
Analysis.Overwrite = true;             % defines if it has tpo be overwritten

root = '/home/ljp/Science/Projects/RLS/';
%root = '/media/RED/Science/Projects/RLS1P/';

date = '2018-06-14' % select date
RUNS = [ 15 ] % select a set of runs 

Analysis.Lineage = 'Nuclear'; % overwrite parameters  % possible values : 'Nuclear', 'Cytoplasmic'
Analysis.Stimulus = 'step'; % overwrite parameters % type of stimulus (step/sinus)
Analysis.StimulusFrequency = 0.2;       % frequency of stimulus (Hz) for phasemap computation

Analysis.RefBrain = 'zBrain_Elavl3-H2BRFP_198layers.nhdr'; % choose refbrain to map onto

% switch Analysis.Lineage
%     case 'Nuclear'
%         Analysis.RefBrain = 'zBrain_Elavl3-H2BRFP_178layers.nhdr'
%         dr'; % choose refbrain to map onto
%     case 'Cytoplasmic'
%         Analysis.RefBrain = 'zBrain_Elavl3-GCaMP5G-178layers.nhdr'; % choose refbrain to map onto
% end
% 
% Analysis.RefBrain = 'zBrain_Elavl3-H2BRFP_178layers.nhdr'; % choose refbrain to map onto

TTT=tic;
%analyse(root, study, date, Analysis, RUNS, @workflowPixel) % run per pixel analysis
%analyse(root, study, date, Analysis, RUNS, @workflowChangeSpace) % run per pixel analysis
%analyse(root, study, date, Analysis, RUNS, @workflowRevertMask) % run per pixel analysis
%analyse(root, study, date, Analysis, RUNS, @workflowDriftcor) % run per pixel analysis
%analyse(root, study, date, Analysis, RUNS, @workflowPixel) % run per pixel analysis
%analyse(root, study, date, Analysis, RUNS, @workflowNeuron) % run per neuron analysis

%analyse(root, study, date, Analysis, RUNS, @workflowRegistration) % run per pixel analysis
analyse(root, study, date, Analysis, RUNS, @workflowReformatPhasemap) % run per pixel analysis

% root = '/media/RED/Science/Projects/RLS1P/';
% date = '2018-06-28' % select date
% RUNS = [ 16 26 ] % select a set of runs 
% analyse(root, study, date, Analysis, RUNS, @workflowReformatPhasemap) % run per pixel analysis
% 
% root = '/home/ljp/Science/Projects/RLS/';
% date = '2018-06-11' % select date
% RUNS = [ 4 ] % select a set of runs 
% analyse(root, study, date, Analysis, RUNS, @workflowReformatPhasemap) % run per pixel analysis
% 
% root = '/home/ljp/Science/Projects/RLS/';
% date = '2018-06-14' % select date
% RUNS = [ 3 8 12 ] % select a set of runs 
% analyse(root, study, date, Analysis, RUNS, @workflowReformatPhasemap) % run per pixel analysis

TIME=toc(TTT);
fprintf('total time for date %s and runs %s : %d\n', date, num2str(RUNS), TIME)

%% Workflow average PhaseMaps:

%% ===== Paralysed + Eyes =====
root = '/home/ljp/Science/Projects/RLS/';

date = '2018-05-24' % select date
RUNS = [ 7 12 16 21 25 ] % select a set of runs 

Analysis.RefBrain = 'zBrain_Elavl3-H2BRFP_198layers.nhdr'; % choose refbrain to map onto

for i = 1: length(RUNS)
    Flist{i} = NT.Focus(root, study, date, RUNS(i), Analysis);         % define focus
end

root = '/media/RED/Science/Projects/RLS1P/';

date = '2018-05-25' % select date
RUNS = [ 11 15 ] % select a set of runs 

Analysis.RefBrain = 'zBrain_Elavl3-H2BRFP_198layers.nhdr'; % choose refbrain to map onto
L = length(Flist);
for i = 1 : length(RUNS)
    Flist{L + i} = NT.Focus(root, study, date, RUNS(i), Analysis);         % define focus
end

root = '/home/ljp/Science/Projects/RLS/';

date = '2018-06-14' % select date
RUNS = [ 15 ] % select a set of runs 

Analysis.RefBrain = 'zBrain_Elavl3-H2BRFP_198layers.nhdr'; % choose refbrain to map onto
L = length(Flist);
for i = 1 : length(RUNS)
    Flist{L + i} = NT.Focus(root, study, date, RUNS(i), Analysis);         % define focus
end
disp(L)

% execute average
averagePhaseMaps(Flist, 'warp', 100)

%% ===== Paralysed - Eyes =====
root = '/media/RED/Science/Projects/RLS1P/';

date = '2018-06-21' % select date
RUNS = [ 28 24 9  ] % select a set of runs 

Analysis.RefBrain = 'zBrain_Elavl3-H2BRFP_198layers.nhdr'; % choose refbrain to map onto

for i = 1: length(RUNS)
    Flist{i} = NT.Focus(root, study, date, RUNS(i), Analysis);         % define focus
end

date = '2018-06-28' % select date
RUNS = [ 16 26  ] % select a set of runs 

Analysis.RefBrain = 'zBrain_Elavl3-H2BRFP_198layers.nhdr'; % choose refbrain to map onto
L = length(Flist);
for i = 1 : length(RUNS)
    Flist{L + i} = NT.Focus(root, study, date, RUNS(i), Analysis);         % define focus
end

root = '/home/ljp/Science/Projects/RLS/';

date = '2018-06-11' % select date
RUNS = [ 4 ] % select a set of runs 

Analysis.RefBrain = 'zBrain_Elavl3-H2BRFP_198layers.nhdr'; % choose refbrain to map onto
L = length(Flist);
for i = 1: length(RUNS)
    Flist{L + i} = NT.Focus(root, study, date, RUNS(i), Analysis);         % define focus
end

date = '2018-06-14' % select date
RUNS = [ 3 8 12 ] % select a set of runs 

Analysis.RefBrain = 'zBrain_Elavl3-H2BRFP_198layers.nhdr'; % choose refbrain to map onto
L = length(Flist);
for i = 1: length(RUNS)
    Flist{L + i} = NT.Focus(root, study, date, RUNS(i), Analysis);         % define focus
end

% execute average
averagePhaseMaps(Flist, 'warp')

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

% workflow drift correction
function workflowDriftcor(F)
    %PrepareNewAnalysis(F)  % rename Analysis folder to Analysis_old; create new Analysis folder; copy Mask folder to new Analysis folder
    driftComputeAndApply(F)
    computeBackground(F);
    createGrayStack(F)
end

% workflow for per neuron analysis
function workflowNeuron(F)
   % Focused.driftCompute(F);
    %driftApply(F);
    %computeBackground(F);
    %createGrayStack(F)
    %segmentBrain(F, 'graystack', 'RC');
    %computeBaseline(F, 'neuron');
    computeDFF(F, 'neuron');
    %dffNeuron(F);
end

% workflow for per pixel analysis (workflowNeuron must have been runned first)
function workflowPixel(F)
%     PlotPhaseMap(F,0,0)

%     Focused.driftCompute(F);
%     driftApply(F);

     computeBaselinePixel(F);
     computeDFF(F, 'pixel');
     computePhaseMap(F, 'pixel', 'dff');
%         switch F.Analysis.Stimulus
%             case 'sinus'
%                 computePhaseMap(F, 'pixel', 'dff');
%         end
end

% workflow for space direction correction
function workflowChangeSpace(F)
  changeSpace(F, 'corrected', 'LAST') 
end

% workflow revertMask
function workflowRevertMask(F)
  revertMask(F,'LAST','RAST');
end

% workflow Registration
function workflowRegistration(F)
    mapToRefBrain(F, 'affine', '', 'graystack');
    mapToRefBrain(F, 'warp', '', 'graystack');
    mapToRefBrain(F, 'reformat', 'affine', 'graystack');
    mapToRefBrain(F, 'reformat', 'warp', 'graystack');
    mapToRefBrain(F, 'convertcoord', 'warp', 'graystack');
    exportToHDF5(F);
end

% ReformatPhasemap
function workflowReformatPhasemap(F)
  computePhaseMap(F, 'pixel', 'dff');
  PlotPhaseMap(F, 100, 0, 0);
  reformatPhasemap(F,'warp', 100);
  %PlotPhaseMapRegistred(F,'wrap', 100);
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
    
    cd(root);
    disp('done');
end