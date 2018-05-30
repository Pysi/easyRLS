function addPrograms(root)
%addPrograms adds the matlab programs to the path and loads the caTools library
% root is the root of the programs (ex /home/ljp/programs)

% adds matlab programs path
addpath(genpath(fullfile(root,'easyRLS','Matlab')));
addpath(genpath(fullfile(root,'NeuroTools','Matlab')));

dir = NT.Focus.architecture(root, 'none');

if ismac
    warning('test if caTools is ok for mac');
elseif isunix
    cd(dir('caTools'))
    [~,~] = loadlibrary('caTools.so',...
                        'caTools.h');
elseif ispc
    cd(dir('caTools'))
    [~,~] = loadlibrary('caTools.dll',...
                        'caTools.h');
else
    disp('Platform not supported')
end