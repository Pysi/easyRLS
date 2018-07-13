% this script helps to understand easyRLS step by step
% Hugo Trentesaux 2018-05-23

%%% This file is a collection of existing function. You can paste them in
%%% your workflow

% see TEMPLATE.m for more information and example

%% view dcimg / tif
    Focused.stackViewer(F);
%% --- %% semi auto ROI on dcimg / tif
semiAutoROI(F); % let you adjust automatic ROI
    %% check if ROI is ok
    Focused.stackViewer(F, 'ROImask'); % stack viewer behaves differently for argument 'ROImask'
%% --- %% drift compute
Focused.driftCompute(F);
    %% see drift correction before applying
    seeDriftCorrection(F);
%% --- %% apply drift if satisfacted
driftApply(F);
%% --- Calculate drift and Apply the correction for every layer
    driftComputeAndApply(F)
    %% view corrected stack
    Focused.stackViewer(F, 'corrected');
%% --- %% compute background
computeBackground(F);
%% --- %% compute gray stack
createGrayStack(F)
    %% view gray stack
    Focused.stackViewer(F, 'graystack')
%% --- %% segment neurons %% --- %%
segmentBrain(F, 'graystack','VB');
%% --- %% compute baseline per neuron / pixel
computeBaseline(F, 'neuron');
computeBaseline(F, 'pixel');
    %% display it
    stackViewer2D(F, 'BaselineNeuron');
    stackViewer2D(F, 'BaselinePixel');
%% --- %%% compute dff per neuron / pixel
computeDFF(F, 'neuron');
computeDFF(F, 'pixel');
    %% display it
    stackViewer2D(F, 'DFFNeuron');
    stackViewer2D(F, 'DFFPixel');
%% --- %% compute phase map neuron / pixel
computePhaseMap(F, 'neuron', 'dff');
computePhaseMap(F, 'pixel', 'dff');
computePhaseMap(F, 'pixel', 'signal');
    %% display it
    Focused.phaseMapViewer(F, 'dff neuron')
    Focused.phaseMapViewer(F, 'dff pixel',100)
    Focused.phaseMapViewer(F, 'signal pixel')
    %% plot it
    PlotPhaseMap(F, 20, 0, 0)
    PlotPhaseMapRegistred(F,'wrap')    
%% choose reference brain
chooseRefBrain(F);
%% do affine transformation
mapToRefBrain(F, 'affine', '', 'graystack');
%% do non-rigid transformation
mapToRefBrain(F, 'warp', '', 'graystack');
%% apply registration affine
mapToRefBrain(F, 'reformat', 'affine', 'graystack');
%% apply registration warp
mapToRefBrain(F, 'reformat', 'warp', 'graystack');
%% stackCoordinates if it was not done in the segementation step
%stackCoord(F); % gets all the coordinates and convert them to micrometers
%% apply registration on neurons coordinates
mapToRefBrain(F, 'convertcoord', 'warp', 'graystack');
%% export values to hdf5 → Thijs
exportToHDF5(F);
%% get zBrain contour in graystack space
mapToRefBrain(F, 'getZBrainContour', 'warp', 'graystack');
%% Reformat phase map
reformatPhasemap(F,'warp',20)
%% Overlay zBrain labels on registered phase map
zBrainLabelsOnPhaseMap(F,0,'','warp'); %'Avg' to overlay on average phase map

%% END

%%
% sinus '- eyes'
Analysis.RefBrain = 'zBrain_Elavl3-H2BRFP_198layers.nhdr'; % choose refbrain to map onto
Flist{1} = NT.Focus(root, study, '2018-06-21', 9, Analysis);         % define focus
%Flist{2} = NT.Focus(root, study, '2018-06-21', 24, Analysis);         % define focus
Flist{2} = NT.Focus(root, study, '2018-06-21', 28, Analysis);         % define focus

Flist{3} = NT.Focus(root, study, '2018-06-28', 16, Analysis);         % define focus
Flist{4} = NT.Focus(root, study, '2018-06-28', 26, Analysis);         % define focus

averagePhaseMaps(Flist)

% sinus '+ eyes'
Flist{1} = NT.Focus(root, study, '2018-05-25', 11, Analysis);         % define focus
Flist{2} = NT.Focus(root, study, '2018-05-25', 15, Analysis);         % define focus

trans_mode = 'warp'
averagePhaseMaps(Flist,trans_mode)