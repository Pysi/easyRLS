% this script helps to understand easyRLS step by step
% Hugo Trentesaux 2018-03-27
clear
clc

%% load library to compute baseline

cd(path.caTools)
[~,~] = loadlibrary('caTools.so',...
                    'caTools.h');
%% add path
cd(path.program)
addpath(genpath('easyRLS/Matlab'))
addpath(genpath('NeuroTools/Matlab'))


%% go to project folder, set parameters, and get focus

F = NT.Focus(path.root, param.study, param.date, param.run);


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                           Version for DCIMG                             %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 


%% if dcimg, you can already view it (if tif, go to imageJ)
Focused.stackViewer(F, [F.run '.dcimg']); % TODO define default name for dcimg
%% semi auto ROI on dcimg
semiAutoROI(F, param.Layers, param.RefIndex, [F.run '.dcimg']); % let you adjust automatic ROI
%% check if ROI is ok
Focused.stackViewer(F, 'ROImask'); % stack viewer behaves differently for argument 'ROImask'
%% shortcut: dcimgRASdrift
dcimgRASdrift(F, 'Run00', {});
%% view corrected stack
Focused.stackViewer(F, 'corrected');
%% compute background
computeBackground(F, 'corrected', param.RefIndex);
%% compute gray stack
createGrayStack(F)
%% view gray stack
Focused.stackViewer(F, 'graystack')
%% segment neurons
segmentBrain(F, 'graystack', param.Layers);

%% compute baseline per neuron
computeBaselineNeuron(F, param.Layers, 50);
%% diplay it
stackViewer2D(F, 'BaselineNeuron', param.Layers);
%% compute dff per neuron
dffNeuron(F, param.Layers);
%% diplay it
stackViewer2D(F, 'DFFNeuron', param.Layers);

%{ 
%PER PIXEL
%% compute baseline per pixel
computeBaselinePixel(F, param.Layers, 50)
%% view baseline
stackViewer2D(F, 'baseline_pixel', param.Layers)
%% compute DFF
dffPixel(F, param.Layers);
%% view DFF
stackViewer2D(F, 'dff', param.Layers);
%% delete unecessary files (including baseline)
clean(F);
%}

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                           Commands for TIF                              %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

%% tif to ras stack
tifToRAS(F, param.Layers, 'ALI');
%% see RAS
Focused.stackViewer(F, 'rawRAS');
%% semi auto ROI
semiAutoROI(F, param.Layers, param.RefIndex, 'rawRAS'); % let you adjust automatic ROI
%% check if ROI is ok
Focused.stackViewer(F, 'ROImask'); % stack viewer behaves differently for argument 'ROImask'
%% drift
driftCompute(F, {'RefLayers', param.RefLayers})

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                           With ref stack                                %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

%% check if ref stack
Focused.stackViewer(F, 'refStack'); 
%% computes the drift on external stack
driftCompute(F, {'RefStack', 'refStack'});
%% see if it is ok
seeDriftCorrection(F);
%% apply if ok
driftApply(F);
%% view corrected stack
Focused.stackViewer(F, 'corrected');
%% compute background
computeBackground(F, 'refStack', 1); % not a valid background
%% compute background
computeBackground(F, 'rawRAS', param.RefIndex); % better
%% segment neurons
segmentBrain(F, 'refStack', param.Layers);
stackCoord(F, param.Layers)


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                           Mapping to ref brain                          %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 


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
