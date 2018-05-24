function m = MmapOnDCIMG(F, tag)
% focused MmapOnDCIMG is the focused wrapper for MmapOnDCIMG
% it creates the info file automatically

	% define default values
	byteskip = 808;
	clockskip = 8;
    space = 'RAST';
	x = 604;
	y = 1024;
	z = 20;
	t = 1500;
    
    origSpace = 'ALIT';
    
    [f, inv, ord] = getTransformation(origSpace, space);

    
    % replace by focus values if available
    if F.IP.width % if values available
        if ord(1) == 2 % if x and y inverted TODO more robust  
            x = F.IP.height;
            y = F.IP.width;
%         t = F.param.NCycles;
        else  
            x = F.IP.width;
            y = F.IP.height;            
        end
    end
    
    % replace default values by exisiting if exist
    try
        load([F.tag(tag) '.mat'], 'x','y','z','t','Z','T','byteskip','clockskip','space');
    catch M
        warning(M.message); % no file is not an error, but a warning
    end
    
    % create necessary variables
    Z = 1:z; % (assumes that Z are oriented this way)
    T = 1:t; %#ok<*NASGU>
    
    save([F.tag(tag) '.mat'], 'x','y','z','t','Z','T','byteskip','clockskip','space');

    m = MmapOnDCIMG(F.tag(tag));

end