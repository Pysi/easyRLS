function mapToRefBrain(F, mode, transformation, mov)
%mapToRefBrain calls CMTK wrappers for different actions
% F     focus
% mode  affine, warp, reformat, convertcoord
% transformation '' if none, or to set automatically
% mov   moving image if necessary

    % shorten refBrainName
    sp = split(F.Analysis.RefBrain, '.');
    refBrainName = sp{1};

    refPath = fullfile(F.dir('RefBrains'), F.Analysis.RefBrain); % points to the refbrain in the refbrain folder
    regPath = fullfile(F.dir('Registration'),refBrainName); % points to the refbrain in the registration folder
    movPath = [F.tag(mov) '.nhdr']; % ex: if mov is 'graystack' tag, movPath will point to 'graystack.nhdr'
    
    switch mode

        % affine registration
        case "affine"
            if isempty(transformation) % if empty, set to default affine transformation
                transformation = autoTransName('affine', mov, refBrainName);
            end
            outPath = fullfile(regPath, [transformation '.xform']);
            CMTK_affine(refPath, movPath, outPath); %%% call cmtk wrapper

        % non-rigid registration
        case "warp"
            if isempty(transformation) % if empty, set to default non-rigid transformation
                transformation = autoTransName('warp', mov, refBrainName);
            end
            initial = fullfile(regPath, string([autoTransName('affine', mov, refBrainName) '.xform']));
            % if does not exist
            if ~exist(initial, 'file')          
                initial = "";
                warning('running warp without initial affine transformation')
            end
            outPath = fullfile(regPath, [transformation '.xform']);
            CMTK_warp(refPath, movPath, outPath, initial); %%% call cmtk wrapper

        case "reformat"
            [transformation, reformatedName] = autoTransName(transformation, mov, refBrainName);
            outPath = fullfile(regPath, [reformatedName '.nrrd']);
            transPath = fullfile(regPath, string([transformation '.xform']));
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
            transformation = autoTransName(transformation, mov, refBrainName);
            transPath = fullfile(regPath, string([transformation '.xform']));
            refCoordinates = CMTK_convertCoord(coordinates, transPath); %#ok<NASGU> %%% call cmtk wrapper
            % saves coordinates in reference brain
            refCoordPath = fullfile(regPath, ['coordinates_' refBrainName '.mat']);
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