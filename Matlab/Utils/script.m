% this script is here to guide through the use of Hugo_easyRLS branch
% Hugo Trentesaux 2018-02-23
% please make sure you have Neurotools to your path
clear
clc
%% add path
cd /home/ljp/Science/Projects/easyRLS/
addpath(genpath('Programs/easyRLS/Matlab'))
addpath(genpath('Programs/NeuroTools/Matlab'))
%% go to project folder, set parameters, and get focus
cd /home/ljp/Science/Projects/RLS/
param.cwd = pwd;
param.date = '2018-03-19';
param.run = 2;
param.Layers = 3:20; 
param.RefLayers = 8:10;
param.RefIndex = 10; 
F = NT.Focus({param.cwd, '', param.date, param.run});
%% other focus
%{
cd /home/ljp/Science/Projects/easyRLS/
param.cwd = pwd;
param.date = '2018-01-11';
param.run = 'Run00';
param.Layers = 3:12; 
param.RefLayers = 8:10;
param.RefIndex = 10; 
F = NT.Focus({param.cwd, '', param.date, param.run});
%% dcimgRASdrift
dcimgRASdrift(F, 'Run00', {}) % this works
%}
%% create binary file from Tif
tifToMmap(F, {'z', param.Layers});
%% or create binary file from DCIMG
% TODO get info from image or mex header reader
%% view hyperstack
Focused.stackViewer(F, 'raw');
%% transpose to RAS
Focused.transposeMmap(F, 'yxzrai', 'xyzras'); % TODO know automatically from parameters
%% view hyperstack
Focused.stackViewer(F, 'rawRAS');
%% compute drift on mmap
driftCompute(F,{...
    'RefLayers', param.RefLayers, ...
    'RefIndex', param.RefIndex, ...
    'Layers', param.Layers, ...
    });
%% see if drift is well corrected
seeDriftCorrection(F); % plays a movie
%% applies drift if it is ok
driftApply(F);
%% view corrected hyperstack
Focused.stackViewer(F, 'corrected'); % similar to | m=Focused.Mmap(F, 'corrected'); imshow(m(:,:,3,10),[300 800]);
%% compute background
computeBackground(F, 'corrected', param.RefIndex);
%% semi auto ROI
semiAutoROI(F, param.Layers, param.RefIndex, 'corrected'); % let you adjust automatic ROI
%% do imregdemons on an other similar brain with a mask
%{
param.run = 6;
Fref = NT.Focus({param.cwd, '', param.date, param.run});
% create defMap (deformation map)
mapToReferenceBrain(F, Fref, param.RefIndex);
% finds ROI using reference brain mask
% use the mask predefined on the reference brain to find the mask for the
% current brain, saves autoROI as a mask.mat file
autoROI(F, Fref)
%}
%% check if ROI is ok (useful if autoguessed, you can then modify again)
Focused.stackViewer(F, 'ROImask'); % stack viewer behaves differently for argument 'ROImask'


%% load library to compute baseline
cd /home/ljp/Science/Projects/easyRLS/
[~,~] = loadlibrary('Programs/easyRLS/Tools/caTools/caTools.so',...
                    'Programs/easyRLS/Tools/caTools/caTools.h');
%% compute baseline using caTools library
caToolsRunquantileLin(F, param.Layers)
%% benchmark
% global COMPUTING
% global WRITING
% caToolsRunquantileLin_BENCHMARK(F, 3)
%% view baseline
stackViewer2D(F, 'baseline', param.Layers)
%% compute gray stack and view it
createGrayStack(F)
Focused.stackViewer(F, 'IP/graystack')
%% compute DFF
t=tic;
dff(F, param.Layers);
toc(t)
%% view DFF
stackViewer2D(F, 'dff', param.Layers);
%% delete unecessary files
clean(F);

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

