function m = MmapOnDCIMG(F, tag)
% focused MmapOnDCIMG is the focused wrapper for MmapOnDCIMG
% it creates the info file automatically

	% define default values
	byteskip = 808;
	clockskip = 8;
    space = 'ALIT';
	x = 1024;
	y = 604;
	z = 20;
	t = 1500;
    
    % replace by focus values if available
    if F.IP.width
        x = F.IP.height; % TODO get RAS to see if it has to be inverted
        y = F.IP.width;
%         t = F.param.NCycles;
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