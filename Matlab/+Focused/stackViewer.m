function stackViewer(F, tag)
% focused version of stackviewer

    titleFig = F.name; % get title

    if strcmp(tag, 'ROImask') % particular case to view mask contour
        load(fullfile(F.dir.IP, 'mask.mat'), 'mask');
        m = Focused.Mmap(F, 'rawRAS'); % get memory map
    else
        mask = [];
        m = Focused.Mmap(F, tag); % get memory map
    end

    stackViewer(m, titleFig, mask)

end