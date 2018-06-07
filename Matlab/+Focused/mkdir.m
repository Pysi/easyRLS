function mkdir(F, dir)
%focused (and secured) way of creating directory

    [~,~,me] = mkdir(F.dir(dir));
    switch me
        case 'MATLAB:MKDIR:DirectoryExists'
            if F.Analysis.Overwrite
                fprintf('overwriting %s\n', F.dir(dir));
            else
                error('can not overwrite %s\n', F.dir(dir));
            end
        otherwise
            fprintf('directory %s created\n', dir);
    end
end