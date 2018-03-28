% this script allows to perform all ROI selections at a time and then run
% all analysis during the night

%% before 
%load library to compute baseline

cd /home/ljp/Science/Projects/easyRLS/
[~,~] = loadlibrary('Programs/easyRLS/Tools/caTools/caTools.so',...
                    'Programs/easyRLS/Tools/caTools/caTools.h');
                
%% add path
cd /home/ljp/Science/Hugo/easyRLS/
addpath(genpath('Programs/easyRLS/Matlab'))
addpath(genpath('Programs/NeuroTools/Matlab'))

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

%% workflow preparation
% preliminary work : set ROI on raw RAS stack on each run you want to work on

cd /home/ljp/Science/Hugo/easyRLS/
param.wd = pwd;
param.date = '2018-01-11';
param.run = 2:2;
param.Layers = 3:20; 
param.RefLayers = 8:10;
param.RefIndex = 10; 
F = NT.Focus(param.wd, '', param.date, param.run);

%% ROI
% semi auto ROI

for run = param.run
    F = NT.Focus(param.wd, '', param.date, param.run); % select the run
    semiAutoROI(F, param.Layers, param.RefIndex, [F.run '.dcimg']); % let you adjust automatic ROI
end

%% workflow 
% does everything in one shot so it can be run in a for or parfor loop

for run = param.run
    F = NT.Focus(param.wd, '', param.date, param.run); % select the run
    fprintf('Starting analysis of run %s\n', F.run);
    
    start_time = tic;
        dcimgRASdrift(F, F.run, {});
        computeBackground(F, 'corrected', param.RefIndex);
        computeBaselinePixel(F, param.Layers)
        createGrayStack(F)
        dffPixel(F, param.Layers);
    disp('Time elapsed for [drift background baseline graystack dff] computation');
    toc(start_time);
end

