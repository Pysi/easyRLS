function stackViewer(F, tag)
%Focused.stackViewer is the focused wrapper for stackViewer
% it creates the memory map and optionally loads the mask

    titleFig = F.name; % get title
    mask = []; % default mask
    sp = split(tag, '.'); % splits the tag to see if there is an extension

    if strcmp(tag, 'ROImask') % particular case to view mask contour
        load(fullfile(F.dir.IP, 'mask.mat'), 'mask');
        try
            m = Focused.Mmap(F, 'rawRAS');
        catch
            try
                m = Focused.MmapOnDCIMG(F, F.run, {});
            catch
                error('could not find rawRAS nor dcimg');
            end
        end
        
    elseif strcmp(sp{end}, 'dcimg') % if extension is dcimg
        m = Focused.MmapOnDCIMG(F, sp{1}, {}); % get memory map on dcimg
        titleFig = [titleFig ' (dcimg)'];
        
    else % normal case
        m = Focused.Mmap(F, tag);
        
    end

    % call stackViewer
    stackViewer(m, titleFig, mask)

end