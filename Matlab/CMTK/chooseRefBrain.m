function chooseRefBrain(F, refbrain)
%chooseRefBrain lets you interactivlety choose between available ref brains
% this function is optionnal, you can manually load the refbrain name to Focus analysis

    refBrainDir = F.dir('RefBrains');
    [~,~] = mkdir(refBrainDir);

    switch nargin
        
        case 1 % interactive
            tmp = [dir(fullfile(refBrainDir, '*.nhdr')); dir(fullfile(refBrainDir, '*.nrrd'))]; % collect all nhdr and nrrd
            disp('please select a reference brain');
            for i=1:size(tmp)
                fprintf('%d) %s\n', i, tmp(i).name);
            end
            ref = input('select number (0 for none)\n? '); % ref brain number
            if ~ref; disp('exiting'); return; end
            refbrain = tmp(ref).name;  
            F.Analysis.RefBrain = refbrain; % loads it in focus
            
        case 2 % select given
            if ~exist(fullfile(refBrainDir, refbrain), 'file') % check existence
                error('%s does not exist', refbrain);
            else
                F.Analysis.RefBrain = refbrain; % loads it in focus
            end
            
        otherwise % bad number of arguments
            error('wat ?')
            
    end

end