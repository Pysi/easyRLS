function stackViewer(F, tag)
%Focused.stackViewer is the focused wrapper for stackViewer
% it creates the memory map and optionally loads the mask

    titleFig = F.name; % get title
    mask = []; % default mask
    sp = split(tag, '.'); % splits the tag to see if there is an extension

    if strcmp(tag, 'ROImask') % particular case to view mask contour
        load(F.tag('mask'), 'mask');
        try
            m = Focused.Mmap(F, 'rawRAS');
        catch
            try
                m = Focused.MmapOnDCIMG(F, 'dcimg');
            catch
                try
                    m = TifAsMatrix(F);
                catch
                    error('could not find rawRAS nor dcimg nor TIF');
                end
            end
        end
        
    elseif strcmp(sp{end}, 'dcimg') % if extension is dcimg
        m = Focused.MmapOnDCIMG(F, 'dcimg'); % get memory map on dcimg
        titleFig = [titleFig ' (dcimg)'];
        
    elseif strcmp(sp{end}, 'tif') % if extension is dcimg
        m = TifAsMatrix(F); % get memory map on dcimg
        titleFig = [titleFig ' (tif)'];
        
    else % normal case
        m = Focused.Mmap(F, tag);
        
    end
    
    minmax = [400 1500];
    if strcmp(tag, 'refStack')
        minmax = [400 4000];
    end

    % call stackViewer
    stackViewer(m, titleFig, mask, minmax)

end