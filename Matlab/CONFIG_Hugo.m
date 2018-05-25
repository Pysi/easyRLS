%% CONFIG

clear; clc

path.caTools = '/home/ljp/Science/Hugo/easyRLS/Programs/easyRLS/Tools/caTools/';
path.program = '/home/ljp/Science/Hugo/easyRLS/Programs/';
path.RefBrains = '/home/ljp/Science/Hugo/easyRLS/Data/2018-03-27/Run 10/RefBrain/';

root = '/home/ljp/Science/Hugo/easyRLS/';
study = 'RLS';
date = '2018-05-21';
run = 0;

cd(path.program)
addpath(genpath('easyRLS/Matlab'))
addpath(genpath('NeuroTools/Matlab'))

F = NT.Focus(root, study, date, run);

cd(root);

F.Analysis.Layers = 3:20;
F.Analysis.RefLayers = 6:6;
F.Analysis.RefIndex = 10;
F.Analysis.RefStack = '';


%% load library to compute baseline

cd(path.caTools)
[~,~] = loadlibrary('caTools.so',...
                    'caTools.h');
