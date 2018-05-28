% this script helps to understand easyRLS step by step
% Hugo Trentesaux 2018-05-23

%% view dcimg / tif
Focused.stackViewer(F, 'dcimg.dcimg'); % TODO define default name for dcimg
Focused.stackViewer(F, 'images.tif');
%% semi auto ROI on dcimg / tif
semiAutoROI(F, 'dcimg.dcimg'); % let you adjust automatic ROI
semiAutoROI(F, 'images.tif'); % let you adjust automatic ROI
%% check if ROI is ok
Focused.stackViewer(F, 'ROImask'); % stack viewer behaves differently for argument 'ROImask'
%% drift compute
Focused.driftCompute(F, 'dcimg.dcimg');
Focused.driftCompute(F, 'images.tif');
%% see drift correction before applying
seeDriftCorrection(F, 'dcimg.dcimg');
seeDriftCorrection(F, 'images.tif');
%% apply drift if satisfacted
driftApply(F, 'dcimg.dcimg');
driftApply(F, 'images.tif');
%% view corrected stack
Focused.stackViewer(F, 'corrected');
%% compute background
computeBackground(F, 'corrected');
%% compute gray stack
createGrayStack(F)
%% view gray stack
Focused.stackViewer(F, 'graystack')
%% segment neurons
segmentBrain(F, 'graystack');
%% compute baseline per neuron / pixel
computeBaselineNeuron(F, 50);
computeBaselinePixel(F, 4:10, 50);
%% diplay it
stackViewer2D(F, 'BaselineNeuron');
stackViewer2D(F, 'BaselinePixel');
%% compute dff per neuron / pixel
dffNeuron(F);
dffPixel(F, 4:10);
%% display it
stackViewer2D(F, 'DFFNeuron');
stackViewer2D(F, 'DFFPixel');
%% compute phase map neuron / pixel
phaseMapPixel(F, 0.2)
%% display it
Focused.phaseMapViewer(F, 'neuron')
Focused.phaseMapViewer(F, 'pixel')

%{
clean(F); %% delete unecessary files (including baseline)
%}
% stackCoord
%% choose reference brain
chooseRefBrain(F, fullfile(path.RefBrains, 'RefBrain.nhdr'));
% TODO automatically create nhdr corresponding to the ref brain nrrd or nhdr
%% do affine transformation
mapToRefBrain(F, 'affine', 'affine', 'graystack')%'refStack')
%% do non-rigid transformation
mapToRefBrain(F, 'warp', 'affine', 'refStack')
%% apply registration
mapToRefBrain(F, 'reformat', 'affine', 'graystack')%'refStack')
%% apply registration on neurons coordinates
mapToRefBrain(F, 'convertcoord', 'affine', '')
%% export values to hdf5 → Thijs
exportToHDF5(F);
%% END