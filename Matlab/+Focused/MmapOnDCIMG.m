function m = MmapOnDCIMG(F)
%+Focused MmapOnDCIMG is the focused wrapper for MmapOnDCIMG
% it creates the info file automatically

    file = dir(fullfile(F.dir('Images'), '*.toml'));
    
    if isempty(file) % no info found, creating one
        fprintf('no info found about dcimg, generating a file\n')
        
        info.filename = 'rec00001.dcimg'; % TODO automatic name detection
        info.size.x = F.IP.height;
        info.size.y = F.IP.width;
        info.size.z = F.param.NLayers;
        info.size.t = F.param.NCycles;
        
        info.byte.depth = 'uint16';
        info.byte.header = 1206;
        info.byte.clock = 32;
        info.byte.endianness = 'little';
        
        info.meta.space = '----';
        info.meta.layers = 1:info.size.z;
        
        toml.write(fullfile(F.dir('Images'), 'info.toml'), info)
        
        error('sample info file generated, please correct it');
        
    else
        infoFile = fullfile(file(1).folder, file(1).name);
        
        l = length(file);
        if l>1
            fprintf('multiple files found, using first :\n\t%s\n', infoFile);
        end
        
        m = MmapOnDCIMG(infoFile);
        
    end

end