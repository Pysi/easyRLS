%% CONFIG

clear; clc

path.caTools = 'C:\Users\FLASH 4.0\Documents\Science\Projects\easyRLS\Programs\easyRLS\Tools\caTools\';
path.program = 'C:\Users\FLASH 4.0\Documents\Science\Projects\easyRLS\Programs';
%path.RefBrains = 'C:\Users\FLASH 4.0\Documents\Science\Projects\easyRLS\Programs\easyRLS\Data\2018-03-27\Run 10\RefBrain\';

root = 'S:\Geoffrey';
study = '';
date = '2018-05-22';
run = 3;

cd(path.program)
addpath(genpath('easyRLS\Matlab'))
addpath(genpath('NeuroTools\Matlab'))

F = NT.Focus(root, study, date, run);

F.Analysis.Layers = 4:10;
F.Analysis.RefLayers = 6:6;
F.Analysis.RefIndex = 10;
F.Analysis.RefStack = '';


%% load library to compute baseline

cd(path.caTools)
[~,~] = loadlibrary('caTools.dll',...
                    'caTools.h');
