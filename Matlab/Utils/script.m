% this script is here to guide through the use of Hugo_easyRLS branch
% Hugo Trentesaux 2018-02-23
% please make sure you have Neurotools to your path
clear
clc

%% go in the project directory
cd /home/ljp/Science/Projects/easyRLS/
param.cwd = pwd;
%% get focus
param.date = '2018-01-11';
param.run = 'Run05';
param.Layers = 3:12; 
F = NT.Focus({param.cwd, '', param.date, param.run});
%% create binary file from Tif
tifToMmap(F, {'z', param.Layers});
%% view hyperstack
stackViewer(F, 'raw')
%% transpose to RAS
Focused.transposeMmap(F, 'yxzrai', 'xyzras')
%% view hyperstack
stackViewer(F, 'rawRAS')
%% compute drift on mmap
param.RefLayers = 8:10;
param.RefIndex = 10; 
driftCompute(F,{...
    'RefLayers', param.RefLayers, ...
    'RefIndex', param.RefIndex, ...
    'Layers', param.Layers, ...
    });
%% see if drift is well corrected
seeDriftCorrection(F);
%% applies drift if it is ok
driftApply(F);
%% view corrected hyperstack
stackViewer(F, 'corrected')

% m=Mmap(F, 'corrected'); imshow(m(:,:,3,10)',[300 800]);

%% define focus on reference stack and take its ROI if existing
%{
param.run = 6;
Fref = NT.Focus({param.cwd, '', param.date, param.run});
% create defMap
mapToReferenceBrain(F, Fref, param.RefIndex);
% finds ROI using reference brain mask
% use the mask predefined on the reference brain to find the mask for the
% current brain, saves autoROI as a mask.mat file
autoROI(F, Fref)
%}

%% if not, select ROI manually on reference brain
selectROI(F, param.RefIndex)
%% check if guessed ROI is ok
maskViewer(F)


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
