function m = MmapOnDCIMG(F, tag, kwargs)
% focused MmapOnDCIMG is the focused wrapper for MmapOnDCIMG
% it creates the info file automatically

	% define default values
    % TODO get this in focus when possible
	byteskip = 808;
	clockskip = 8;
    space = 'ALI';
	x = 1024;
	y = 604;
	z = 20;
	t = 1500;
    
    % replace default values by exisiting if exist
    try
        load(fullfile(F.dir.data, [tag '.mat']), 'x','y','z','t','Z','T','byteskip','clockskip','space');
    catch M
        warning(M.message); % no file is not an erreor, but a warning
    end

	% parse input
    % TODO remove kwargs once they are found in focus
	in = inputParser;
	in.addParameter('byteskip', byteskip);
	in.addParameter('clockskip', clockskip);
	in.addParameter('space', space);
	in.addParameter('x', x);
	in.addParameter('y', y);
	in.addParameter('z', z);
	in.addParameter('t', t);
	in.parse(kwargs{:})

	% get results
	byteskip = in.Results.byteskip;
	clockskip = in.Results.clockskip;
	space = in.Results.space;
	x = in.Results.x;
	y = in.Results.y;
	z = in.Results.z;
	t = in.Results.t;
    
    % create necessary variables
    Z = 1:z; % (assumes that Z are oriented this way)
    T = 1:t; %#ok<*NASGU>
    
    save(fullfile(F.dir.data, [tag '.mat']), 'x','y','z','t','Z','T','byteskip','clockskip','space');

    m = MmapOnDCIMG(fullfile(F.dir.data, tag));

end