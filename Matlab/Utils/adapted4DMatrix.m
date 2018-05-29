function m = adapted4DMatrix(F, tag)
%adapted4DMatrix returns Mmap, MmapOnDCIMG, TifAsMatrix depending on the tag

    bin = false;
    dcimg = false;
    tif = false;
    
    % if source is asked, search it in focus
    if strcmp(tag,'source')
        switch F.extra.Source
            case 'dcimg'
                dcimg = true;
            case 'tif'
                tif = true;
        end
    else % if not 'source', parse the tag
        switch tag
            case 'dcimg' % if dcimg
                dcimg = true;
            case 'tif' % if tif
                tif = true;
            otherwise % regular case
                bin = true; 
        end
    end

    if bin % if standard binary stack
        m = Focused.Mmap(F, tag); % get the memory map        
    elseif dcimg % if dcimg is true, do it on dcimg
        m = Focused.MmapOnDCIMG(F);      
    elseif tif % if tif is true, do it on tif
        m = TifAsMatrix(F);     
    else
        error('%s tag not implemented', tag); % should not happen anymore
    end
end