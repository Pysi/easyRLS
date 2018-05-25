function chooseRefBrain(F, refbrain)
%chooseRefBrain creates a RefBrain.nhdr linking to the chosen brain or let
%you interactivlety choose between available ref brains

    [~,~] = mkdir(F.dir('RefBrain'));

    switch nargin
        case 1 % interactive
            refBrainDir = input('give refbrains directory:\n? ','s');
            tmp = dir(fullfile(refBrainDir, '*.nhdr')); % get all nrrd or nhdr (TODO add nifti)
            disp('please select a NRRD header (.nhdr) with an absolute path to the binary file');
            disp('it will be copied to your focused directory');
            for i=1:size(tmp)
                fprintf('%d) %s\n', i, tmp(i).name);
            end
            ref = input('select number (0 for none)\n? '); % ref brain number
            if ~ref; disp('exiting'); return; end
            refbrain = fullfile(tmp(ref).folder, tmp(ref).name);        
        case 2 % select given
            if ~exist(refbrain, 'file')
                error('%s does not exist', refbrain);
            end
        otherwise % bad number of arguments
            error('wat ?')
    end

    refPath = F.tag('RefBrain');
    if exist(refPath, 'file')
        warning('overwriting existing header');
    end

    % make copy
    command = join(["cp -v", escape(refbrain), escape(refPath)]);
    [~, ~] = unix(command, '-echo');

end