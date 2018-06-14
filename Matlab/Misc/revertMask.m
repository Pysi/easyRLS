function revertMask(F, inMode, outMode)
% this function is used to revert the mask if it was not RAS

    load(F.tag('mask')); % get mask

    save([F.tag('mask') '_old_' inMode], 'mask'); % backup

    % transpose mask
    t = getTransformation(inMode, outMode);
    mask = applyTransformation(mask, t);

    save(F.tag('mask'), 'mask'); % overwrites old

end