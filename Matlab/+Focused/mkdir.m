function mkdir(F, dir, silent)
%focused (and secured) way of creating directory

    % silent creation
    if ~exist('silent', 'var')
        silent = false;
    end
    
    [~,~,me] = mkdir(F.dir(dir));
    switch me
        case 'MATLAB:MKDIR:DirectoryExists'
            if silent % do nothing
            elseif F.Analysis.Overwrite
                fprintf('overwriting %s\n', F.dir(dir));
            else
                error('can not overwrite %s\nset "Overwrite" to "true" or delete de repertory', F.dir(dir));
            end
        otherwise
            fprintf('directory %s created\n', dir);
    end
end