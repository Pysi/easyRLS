%% DEFAULT CONFIG : do not change

% if you want to set your config copy it in an other file (ex CONFIG_Hugo.m)
% and ignore it in the git

clear; clc

cd /home/ljp/Programs/
addpath(genpath('easyRLS/Matlab'))
addpath(genpath('NeuroTools/Matlab'))

root = '/home/ljp/Science/Projects/RLS/';
study = '';
date = '0000-00-00';
run = 0;

F = NT.Focus(root, study, date, run);

F.Analysis.Layers = 3:20;
F.Analysis.RefLayers = 8:10;
F.Analysis.RefIndex = 10;
F.Analysis.RefStack = '';

%% Linux: load library to compute baseline 

cd(F.dir('caTools'))
[~,~] = loadlibrary('caTools.so',...
                    'caTools.h');

%% Windows load library to compute baseline 

cd(F.dir('caTools'))
[~,~] = loadlibrary('caTools.dll',...
                    'caTools.h');

% you can add your own functions in the CONFIG_Hugo.m or CONFIG_Geoffrey.m ...




