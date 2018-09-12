function m = MmapOnDCIMG(F)
% focused MmapOnDCIMG is the focused wrapper for MmapOnDCIMG
% it creates the info file automatically
    
    % replace default values by exisiting if exist
    dcimgMatfile = [F.tag('dcimg') '.mat'];
    
    try % if mat file already existing (ex: manually created)
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
        z = 20;
        t = F.param.NCycles;

%         [~, ~, ord] = getTransformation(origSpace, space);

        % replace by focus values if available
        if isfield(F.IP, 'width') % if values available
%             if ord(1) == 2 % if x and y inverted, TODO: more robust  
%                 y = F.IP.height;
%                 x = F.IP.width;
%             else  
                x = F.IP.width;
                y = F.IP.height;            
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