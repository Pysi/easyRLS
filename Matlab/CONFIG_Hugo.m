%% CONFIG

clear; clc

path.caTools = '/home/ljp/Science/Hugo/easyRLS/Programs/easyRLS/Tools/caTools/';
path.program = '/home/ljp/Science/Hugo/easyRLS/Programs/';
path.RefBrains = '/home/ljp/Science/Hugo/easyRLS/Data/2018-03-27/Run 10/RefBrain/';

root = '/home/ljp/Science/Hugo/easyRLS/';
study = '';
date = '2018-01-11';
run = 5;

cd(path.program)
addpath(genpath('easyRLS/Matlab'))
addpath(genpath('NeuroTools/Matlab'))

F = NT.Focus(root, study, date, run);

F.Analysis.Layers = 4:10;
F.Analysis.RefLayers = 6:6;
F.Analysis.RefIndex = 10;
F.Analysis.RefStack = '';


%% load library to compute baseline

cd(path.caTools)
[~,~] = loadlibrary('caTools.so',...
                    'caTools.h');
