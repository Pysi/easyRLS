% this script is here to guide through the use of Hugo_easyRLS branch
% Hugo Trentesaux 2018-02-23
% please make sure you have Neurotools to your path
clear
clc

%% go to project folder, set parameters, and get focus
cd /home/ljp/Science/Projects/easyRLS/
param.cwd = pwd;
param.date = '2018-01-11';
param.run = 'Run05';
param.Layers = 3:12; 
param.RefLayers = 8:10;
param.RefIndex = 10; 
F = NT.Focus({param.cwd, '', param.date, param.run});
%% create binary file from Tif
tifToMmap(F, {'z', param.Layers});
%% or create binary file from DCIMG
% TODO get info from image or mex header reader
%% view hyperstack
stackViewer(F, 'raw');
%% transpose to RAS
Focused.transposeMmap(F, 'yxzrai', 'xyzras'); % TODO know automatically from parameters
%% view hyperstack
stackViewer(F, 'rawRAS');
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
stackViewer(F, 'corrected'); % similar to | m=Focused.Mmap(F, 'corrected'); imshow(m(:,:,3,10),[300 800]);
%% semi auto ROI
semiAutoROI(F, param.Layers, param.RefIndex); % let you adjust automatic ROI

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
stackViewer(F, 'ROImask'); % stack viewer behaves differently for argument 'ROImask'


%% load library to compute baseline
[~,~] = loadlibrary('/home/ljp/Science/Projects/easyRLS/Programs/easyRLS/Tools/caTools/caTools.so',...
                    '/home/ljp/Science/Projects/easyRLS/Programs/easyRLS/Tools/caTools/caTools.h');
%% compute baseline using caTools library
caToolsRunquantileLin(F, param.Layers)
%% view baseline
stackViewer2D(F, 'baseline', param.Layers)
%% compute gray stack and view it
createGrayStack(F)
stackViewer(F, 'IP/graystack')
%% compute background
param.background = 400;
%% compute DFF
t=tic;
dff(F, param.Layers, param.background);
toc(t)
%% view DFF
sigViewer2D(F, 'dff', param.Layers)

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
