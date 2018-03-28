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

%% go to project folder, set parameters, and get focus
cd /home/ljp/Science/Hugo/easyRLS/
param.wd = pwd;
param.date = '2018-01-11';
param.run = 'Run05';
param.Layers = 3:20; 
param.RefLayers = 8:10;
param.RefIndex = 10; 
F = NT.Focus(param.wd, '', param.date, param.run);
%% if dcimg, you can already view it (if tif, go to imageJ)
Focused.stackViewer(F, [F.run '.dcimg']);
%% semi auto ROI on dcimg
semiAutoROI(F, param.Layers, param.RefIndex, [F.run '.dcimg']); % let you adjust automatic ROI
%% check if ROI is ok
Focused.stackViewer(F, 'ROImask'); % stack viewer behaves differently for argument 'ROImask'
%% shortcut: dcimgRASdrift
dcimgRASdrift(F, 'Run00', {});
Focused.stackViewer(F, 'corrected');
%% compute background
computeBackground(F, 'corrected', param.RefIndex);
%% compute gray stack
createGrayStack(F)
%% view gray stack
Focused.stackViewer(F, 'IP/graystack')
%% compute baseline using caTools library
computeBaselinePixel(F, param.Layers, 50)
%% view baseline
stackViewer2D(F, 'baseline_pixel', param.Layers)
%% compute DFF
dffPixel(F, param.Layers);
%% view DFF
stackViewer2D(F, 'dff', param.Layers);
%% delete unecessary files (including baseline)
clean(F);
%% END
