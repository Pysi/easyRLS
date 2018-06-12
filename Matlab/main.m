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
    %% view corrected stack
    Focused.stackViewer(F, 'corrected');
%% --- %% compute background
computeBackground(F);
%% --- %% compute gray stack
createGrayStack(F)
    %% view gray stack
    Focused.stackViewer(F, 'graystack')
%% --- %% segment neurons %% --- %%
segmentBrain(F, 'graystack');
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
    Focused.phaseMapViewer(F, 'dff pixel')
    Focused.phaseMapViewer(F, 'signal pixel')
    
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
stackCoord(F); % gets all the coordinates and convert them to micrometers
%% apply registration on neurons coordinates
mapToRefBrain(F, 'convertcoord', 'warp', 'graystack');
%% export values to hdf5 → Thijs
exportToHDF5(F);
%% END