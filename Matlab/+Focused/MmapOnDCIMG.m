function m = MmapOnDCIMG(F)
%+Focused MmapOnDCIMG is the focused wrapper for MmapOnDCIMG
% it creates the info file automatically

    file = dir(fullfile(F.dir('Images'), '*.toml'));
    
    try % try to get x and y from focus (if img found)
        x = F.IP.height;
        y = F.IP.width;
    catch
        x = 0;
        y = 0;
    end
    
    if isempty(file) % no info found, creating one
        fprintf('no info found about dcimg, generating a file\n')
        infoFile = fullfile(F.dir('Images'), 'info.toml');
        
        info.filename = 'rec00001.dcimg'; % TODO automatic name detection
        info.size.x = x;
        info.size.y = y;
        info.size.z = F.param.NLayers;
        info.size.t = F.param.NCycles;
        
        info.byte.depth = 'uint16';
        info.byte.header = 0;
        info.byte.clock = 0;
        info.byte.endianness = 'little';
        
        info.meta.space = '----';
        info.meta.layers = 1:info.size.z;
        
        toml.write(infoFile, info)
        
        help(infoFile);
        error('sample info file generated, please correct it');
    end
    
    infoFile = fullfile(file(1).folder, file(1).name);

    l = length(file);
    if l>1 % tells if several toml files found
        fprintf('multiple files found, using first :\n\t%s\n', infoFile);
    end
    
    % read info from existing file
    info = toml.read(infoFile);
    
    if info.meta.space == '----'
        help(infoFile);
        error('please edit sample file !')
    end
    
    m = MmapOnDCIMG(infoFile);
    
end


function help(infoFile)

    helpLink = 'https://github.com/LaboJeanPerrin/wiki/blob/master/easyRLS-doc/dcimgTOML.md';
    fprintf('you can find help on <a href="%s">the doc</a> about how to fill this file\n', helpLink);
    if isunix
        unix(sprintf('gedit "%s"', infoFile));
    end 
end