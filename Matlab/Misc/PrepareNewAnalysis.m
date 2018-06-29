function PrepareNewAnalysis(F)
% Creat new Analysis folder and copy Mask folder in ti

movefile( [F.dir('Analysis') ], [F.dir('Analysis') '_old']); % backup

mkdir(F.dir('Analysis'))

copyfile( [F.dir('Run') '/Analysis_old/Mask'  ], [F.dir('Analysis') '/Mask' ]); % backup



end