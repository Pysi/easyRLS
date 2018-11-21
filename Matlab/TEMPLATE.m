%% TEMPLATE : do not change this file !!!

% if you want to change this file
% create instead a copy in other file (ex TEMPLATE_Hugo.m)

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                                                                       %
%                                                                       %
%                         DO NOT EDIT ANYMORE !                         %
%                                                                       %
%                                                                       %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

clear; clc

%% add programs

addPrograms('/home/ljp/');

%% sample focus

root = '/home/ljp/Science/Projects/RLS/';
study = '';
date = '2018-12-31';
run = 0;

F = NT.Focus(root, study, date, run);

% sample parameters

clear Analysis

Analysis.Layers = 1:20;             % Layers to analyse
Analysis.RefIndex = 1;              % index of the reference frame for drift correction
Analysis.RefStack = '';             % external reference stack if exists
Analysis.BaselineWindow = 50;       % time in seconds of the baseline window
Analysis.BaselinePercentile = 10;   % percentile for baseline computation
Analysis.Lineage = 'Nuclear';       % possible values : 'Nuclear', 'Cytoplasmic'
Analysis.StimulusFrequency = 0.2;   % frequency of stimulus (Hz) for phasemap computation
Analysis.Stimulus = 'sinus';        % type of stimulus (step/sinus)
Analysis.Overwrite = false;         % true if program is allowed to overwrite
Analysis.RefBrain = 'zBrain_Elavl3-H2BRFP_198layers.nhdr'; % choose refbrain to map onto

% loads the parameters in the current focus
F.Analysis = Analysis;

%% sample viewer (collection of all viewer functions)

Focused.stackViewer(F, 'source');                   % view raw stack
Focused.stackViewer(F, 'ROImask');                  % view the user defined ROI
seeDriftCorrection(F, 5);                           % plays a movie of corrected images for layer 5                                  
Focused.stackViewer(F, 'corrected', [400 1200]);    % plots the corrected stack with values between 400 and 1200
Focused.stackViewer(F, 'graystack');                % view the graystack
stackViewer2D(F, 'BaselineNeuron');                 % view the baseline computed per neuron
stackViewer2D(F, 'DFFNeuron');                      % view the dff computed per neuron
stackViewer2D(F, 'BaselinePixel');                  % view the baseline computed per pixel
stackViewer2D(F, 'DFFPixel');                       % view the dff computed per pixel
Focused.phaseMapViewer(F, 'signal pixel',1000);     % view the phasemap computed on signal per pixel
Focused.phaseMapViewer(F, 'dff pixel',10);          % view the phasemap computed on dff per pixel
Focused.phaseMapViewer(F, 'dff neuron');            % view the phasemap computed on dff per neuron

%% sample functions (to run the analysis function by function)

semiAutoROI(F);                     % lets the user select the ROI
Focused.driftCompute(F, 'both')     % computes the fast drift then the slow drift
driftApply(F);                      % applies computed drift
driftComputeAndApply(F, 'on');      % calculates the drift for every layer independently

computeBackground(F);               % computes the background value for each layer
createGrayStack(F);                 % creates a gray stack by averaging on image each 77 
segmentBrain(F, 'graystack','RC');  % segment brain using the Raphaël Candelier function

% --- per neuron
computeBaseline(F, 'neuron');       % computes baseline per neuron
computeDFF(F, 'neuron');            % computes dff per neuron
computePhaseMap(F, 'neuron');       % computes phasemap per neuron

% --- per pixel
computeBaseline(F, 'pixel');        % computes baseline per pixel
computeDFF(F, 'pixel');             % computes dff per pixel
phaseMapPixel(F);                   % computes phasemap per pixel on dff
computePhaseMap(F, 'pixel', 'signal');  % computes baseline per pixel on signal
computePhaseMap(F, 'pixel', 'dff');     % computes baseline per pixel on dff (Geoffrey's function)

% --- export
mapToRefBrain(F, 'affine', '', 'graystack');                % maps graystack to reference brain (affine)
mapToRefBrain(F, 'convertcoord', 'affine', 'graystack');    % converts coordinates of segmented neurons
exportToHDF5(F);                                            % export data ub hdf5 file


%%






% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                                                                       %
%                                                                       %
%                         DO NOT EDIT ANYMORE !                         %
%                                                                       %
%                                                                       %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %








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