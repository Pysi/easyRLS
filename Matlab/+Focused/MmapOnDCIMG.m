function m = MmapOnDCIMG(F, tag)
% focused MmapOnDCIMG is the focused wrapper for MmapOnDCIMG
% it creates the info file automatically
    
    % replace default values by exisiting if exist
    
    try % if mat file already existing (ex: manually created)
        load([F.tag(tag) '.mat'], 'x','y','z','t','Z','T','byteskip','clockskip','origSpace');
        
    catch M % else, write it
        warning(M.message); % no file is not an error, but a warning
        warning('no file found, creating one')
         
        % define default values
        byteskip = 808;
        clockskip = 8;
        origSpace = 'ALIT';
        space = 'RAST';
        x = 604;
        y = 1024;
        z = 20;
        t = 1500;

        [~, ~, ord] = getTransformation(origSpace, space);

        % replace by focus values if available
        if isfield(F.IP, 'width') % if values available
            if ord(1) == 2 % if x and y inverted TODO more robust  
                x = F.IP.height;
                y = F.IP.width;
                % t = F.param.NCycles;
            else  
                x = F.IP.width;
                y = F.IP.height;            
            end
        else
            warning('no tif file found, using default parameters (adjust them manually)');
        end
    
        % create necessary variables
        Z = 1:z; % (assumes that Z are oriented this way)
        T = 1:t; %#ok<*NASGU>
        save([F.tag(tag) '.mat'], 'x','y','z','t','Z','T','byteskip','clockskip','origSpace');
    end
    
    m = MmapOnDCIMG(F.tag(tag));

end