function m = MmapOnDCIMG(F, tag, kwargs)
% focused MmapOnDCIMG is the focused wrapper for MmapOnDCIMG
% it creates the info file automatically

	% define default values
	byteskip = 808;
	clockskip = 8;
	x = 1024;
	y = 604;
	z = 20;
	t = 1500;

	% parse input
	in = inputParser;
	in.addParameter('byteskip', byteskip);
	in.addParameter('clockskip', clockskip);
	in.addParameter('x', x);
	in.addParameter('y', y);
	in.addParameter('z', z);
	in.addParameter('t', t);
	in.parse(kwargs{:})

	% get results
	byteskip = in.Results.byteskip;
	clockskip = in.Results.clockskip;
	x = in.Results.x;
	y = in.Results.y;
	z = in.Results.z;
	t = in.Results.t;
    
    % create necessary variables
    Z = 1:z; % (assumes that Z are oriented this way)
    T = 1:t; %#ok<*NASGU>
    
    save(fullfile(F.dir.data, [tag '.mat']), 'x','y','z','t','Z','T','byteskip','clockskip')

    m = MmapOnDCIMG(fullfile(F.dir.data, tag));

end