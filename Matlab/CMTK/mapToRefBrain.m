function mapToRefBrain(F, mode, transformation, mov)
%mapToRefBrain calls CMTK wrappers for different actions
% F     focus
% mode  affine, warp, reformat, convertcoord
% transformation '' if none
% mov   moving image if necessary

if exist('mov', 'var')
    refPath = F.tag('RefBrain'); % TODO create reference
    movPath = [F.tag(mov) '.nhdr'];
end

switch mode
    case "affine"
        outPath = fullfile(F.dir('Registration'), [transformation '.xform']);
        CMTK_affine(refPath, movPath, outPath);
    case "warp"
        outPath = fullfile(F.dir('Registration'), 'warp.xform');
        if transformation
            initial = fullfile(F.dir('Registration'), string([transformation '.xform']));
        else
            initial = "";
            warning('running warp without initial affine transformation')
        end
        CMTK_warp(refPath, movPath, outPath, initial);
    case "reformat"
        outPath = fullfile(F.dir('Registration'), 'reformated.nrrd');
        transPath = fullfile(F.dir('Registration'), string([transformation '.xform']));
        CMTK_reformat(refPath, movPath, outPath, transPath);        
    case "convertcoord"
        coordPath = fullfile(F.dir('Segmentation'), 'coordinates.mat');
        load(coordPath, 'coordinates', 'numberNeuron');
        transPath = fullfile(F.dir('Registration'), string([transformation '.xform']));
        refCoordinates = CMTK_convertCoord(coordinates, transPath);
        refCoordPath = fullfile(F.dir('RefBrain'), 'refCoordinates.mat');
        save(refCoordPath, 'refCoordinates', 'numberNeuron');
    otherwise
        disp("no such mode, doing nothing");        
end