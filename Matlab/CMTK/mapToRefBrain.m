function mapToRefBrain(F, mov, mode, transformation)
%mapToRefBrain calls CMTK wrappers for different actions
% F     focus
% ref   reference fixed image
% mov   moving image
% mode  affine, warp, reformat
% transformation to use only needed for reformat

refPath = fullfile(F.dir.RefBrain, 'RefBrain.nhdr'); % TODO create reference
movPath = fullfile(F.dir.files, [mov '.nhdr']);

switch mode
    case "affine"
        outPath = fullfile(F.dir.RefBrain, 'affine.xform');
        CMTK_affine(refPath, movPath, outPath);
    case "warp"
        outPath = fullfile(F.dir.RefBrain, 'warp.xform');
        if exist('transformation', 'var')
            initial = fullfile(F.dir.RefBrain, string([transformation '.xform']));
        else
            initial = "";
            warning('running warp without initial affine transformation')
        end
        CMTK_warp(refPath, movPath, outPath, initial);
    case "reformat"
        outPath = fullfile(F.dir.RefBrain, 'reformated.nrrd');
        transPath = fullfile(F.dir.RefBrain, string([transformation '.xform']));
        CMTK_reformat(refPath, movPath, outPath, transPath);        
    otherwise
        disp("no such mode, doing nothing");        
end