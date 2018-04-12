% this script helps to understand easyRLS step by step
% Hugo Trentesaux 2018-03-27
clear
clc
%% load library to compute baseline
cd /home/ljp/Science/Hugo/easyRLS/
[~,~] = loadlibrary('Programs/easyRLS/Tools/caTools/caTools.so',...
                    'Programs/easyRLS/Tools/caTools/caTools.h');
%% add path
cd /home/ljp/Science/Hugo/easyRLS/
addpath(genpath('Programs/easyRLS/Matlab'))
addpath(genpath('Programs/NeuroTools/Matlab'))

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%                           Version for DCIMG                             %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

%% go to project folder, set parameters, and get focus
param.Layers = 3:12; 
param.RefLayers = 8:10;
param.RefIndex = 10; 
F = NT.Focus('/home/ljp/Science/Hugo/easyRLS/', '', '2018-03-27', 'Run 10');
%% if dcimg, you can already view it (if tif, go to imageJ)
Focused.stackViewer(F, [F.run '.dcimg']);
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
Focused.stackViewer(F, 'IP/graystack')
%% segment neurons
segmentBrain(F, param.Layers);
%% compute baseline per neuron
computeBaselineNeuron(F, param.Layers, 50);
%% diplay it
stackViewer2D(F, 'baseline_neuron', param.Layers);
%% compute dff per neuron
dffNeuron(F, param.Layers);
%% diplay it
stackViewer2D(F, 'dff_neuron', param.Layers);

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
tifToRAS(F, param.Layers);
%% see RAS
Focused.stackViewer(F, 'rawRAS');
%% semi auto ROI
semiAutoROI(F, param.Layers, param.RefIndex, 'rawRAS'); % let you adjust automatic ROI
%% check if ROI is ok
Focused.stackViewer(F, 'ROImask'); % stack viewer behaves differently for argument 'ROImask'
%% check if ref stack
Focused.stackViewer(F, 'refStack'); 
%% computes the drift on external stack
driftCompute(F, {});%'RefStack', 'refStack'})
%% see if it is ok
seeDriftCorrection(F);
%% apply if ok
driftApply(F);







%% END
