function mapToRefBrain(F, mode, transformation, mov)
%mapToRefBrain calls CMTK wrappers for different actions
% F     focus
% mode  affine, warp, reformat, convertcoord
% transformation '' if none, or to set automatically
% mov   moving image if necessary

    if exist('mov', 'var')
        refPath = fullfile(F.dir('RefBrains'), F.Analysis.RefBrain); % points to the refbrain in the refbrain folder
        movPath = [F.tag(mov) '.nhdr']; % ex: if mov is 'graystack' tag, movPath will point to 'graystack.nhdr'
    end

    switch mode

        % affine registration
        case "affine"
            if isempty(transformation) % if empty, set to default affine transformation
                transformation = autoTransName('affine', mov, F.Analysis.RefBrainName);
            end
            outPath = fullfile(F.dir('Registration'), [transformation '.xform']);
            CMTK_affine(refPath, movPath, outPath); %%% call cmtk wrapper

        % non-rigid registration
        case "warp"
            if isempty(transformation) % if empty, set to default non-rigid transformation
                transformation = autoTransName('warp', mov, F.Analysis.RefBrainName);
            end
            initial = fullfile(F.dir('Registration'), string([autoTransName('affine', mov, F.Analysis.RefBrainName); '.xform']));
            % if does not exist
            if ~exist(initial, 'file')          
                initial = "";
                warning('running warp without initial affine transformation')
            end
            outPath = fullfile(F.dir('Registration'), [transformation '.xform']);
            CMTK_warp(refPath, movPath, outPath, initial); %%% call cmtk wrapper

        case "reformat"
            [transformation, reformatedName] = autoTransName(transformation, mov, F.Analysis.RefBrainName);
            outPath = fullfile(F.dir('Registration'), [reformatedName '.nrrd']);
            transPath = fullfile(F.dir('Registration'), string([transformation '.xform']));
            % if does not exist
            if ~exist(transPath, 'file')          
                error('"%s": transformation not found', transformation)
            end
            CMTK_reformat(refPath, movPath, outPath, transPath); %%% call cmtk wrapper       

        case "convertcoord"
            % loads coordinates in micrometers
            coordPath = fullfile(F.dir('Segmentation'), 'coordinates.mat');
            load(coordPath, 'coordinates', 'numberNeuron');
            % transformation path
            transformation = autoTransName(transformation, mov, F.Analysis.RefBrainName);
            transPath = fullfile(F.dir('Registration'), string([transformation '.xform']));
            refCoordinates = CMTK_convertCoord(coordinates, transPath); %#ok<NASGU> %%% call cmtk wrapper
            % saves coordinates in reference brain
            refCoordPath = fullfile(F.dir('Registration'), ['coordinates_' F.Analysis.RefBrainName '.mat']);
            save(refCoordPath, 'refCoordinates', 'numberNeuron');

        otherwise
            disp("no such mode: %s, doing nothing", mode);      

    end
end

function [transformation, reformatedName] = autoTransName(transformation, mov, refBrainName)
% this function treats 'affine' and 'warp' as default cases

    switch transformation % detect default cases
        case 'affine' % search affine
            transformation = [ 'AFFINE_' mov '_TO_' refBrainName ];
            reformatedName = [ 'AFFINE_' mov '_ON_' refBrainName ];
        case 'warp' % search non-rigid
            transformation = [ 'WARP_' mov '_TO_' refBrainName ];
            reformatedName = [ 'WARP_' mov '_ON_' refBrainName ];
        otherwise % personal transformation
            % transformation does not change
            reformatedName = [ 'reformated-with_' transformation ];                
    end

end