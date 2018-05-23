function m = adapted4DMatrix(F, tag)
%adapted4DMatrix returns Mmap, MmapOnDCIMG, TifAsMatrix depending on the tag

    bin = false;
    dcimg = false;
    tif = false;

    sptag = split(tag, '.');

    if length(sptag) == 1 % if no extension (regular case)
        bin = true;
    else
        switch sptag{end}
            case 'dcimg' % if extension is dcimg
                dcimg = true;
            case 'tif' % if alias for tif
                tif = true;
            otherwise
                error('case not implemented for tag %s', tag);
        end
    end
    
    if bin % if standard binary stack
        m = Focused.Mmap(F, tag); % get the memory map        
    elseif dcimg % if dcimg is true, do it on dcimg
        m = Focused.MmapOnDCIMG(F, sptag{1}, {});      
    elseif tif % if tif is true, do it on tif
        m = TifAsMatrix(F);     
    else
        error('%s tag not implemented', tag);
    end
    
end