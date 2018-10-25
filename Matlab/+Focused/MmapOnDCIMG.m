function m = MmapOnDCIMG(F)
% focused MmapOnDCIMG is the focused wrapper for MmapOnDCIMG
% it creates the info file automatically
    
    % replace default values by exisiting if exist
    dcimgMatfile = [F.tag('dcimg') '.mat'];
    
    % TODO uniformize the place where we get information !!!!!!!!!!!!
    % pour éviter de prendre l'information à mille endroits du programme
    
    try % if mat file already existing (ex: manually created, created before)
        load(dcimgMatfile, 'x','y','z','t','Z','T','byteskip','clockskip','origSpace');
        
    catch % M % else, write it
        warning('dcimgMatfile not found, generating one');
        
        % define default values (will be replaced if more info is collected)
        byteskip = 808;
        clockskip = 8;
        origSpace = 'ARIT';
        space = 'RAST';
        x = 614;
        y = 1018;
        z = F.param.NLayers;
        t = F.param.NCycles;

        try % tries to find a .toml file, if not, take default
            file = dir(fullfile(F.dir('Images'), '*.toml'));
            info = toml.read(fullfile(file.folder, file.name));
            byteskip = info.dcimg.header;
            clockskip = info.dcimg.clockskip;
            fprintf('found byteskip=%d and clockskip=%d in toml file\n', byteskip, clockskip);
        catch % keep default values 
        end

%         [~, ~, ord] = getTransformation(origSpace, space);

        % replace by focus values if available
        if isfield(F.IP, 'width') % if values available
%             if ord(1) == 2 % if x and y inverted, TODO: more robust  
                x = F.IP.height;
                y = F.IP.width;
%             else  
%                 x = F.IP.width;
%                 y = F.IP.height;            
%             end
        else
            warning('no tif file found, using default parameters (adjust them manually)');
        end
        if isfield(F.extra, 'sourceSpace')
            origSpace = F.extra.sourceSpace;
        else
            warning('no space provided, using default (%s)', origSpace)
        end
    
        % create necessary variables
        Z = 1:z; % (assumes that Z are oriented this way)
        T = 1:t; %#ok<*NASGU>
        save([F.tag('dcimg') '.mat'], 'x','y','z','t','Z','T','byteskip','clockskip','origSpace');
    end
    
    m = MmapOnDCIMG(F.tag('dcimg'));

end