function mmap = dcimgToMmap(F, tag, kwargs)
% focused dcimgToMmap parse kwargs and calls dcimgToMmap
% the kwargs could be guessed from focus

	% define default values
	byteskip = 808;
	clockskip = 8;
	x = 1024;
	y = 600;
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

	% set directories
	inputFile = fullfile(F.dir.data, [tag '.dcimg']);
	
	% call dcimg
	mmap = dcimgToMmap(inputFile, x, y, z, t, byteskip, clockskip);
    
end
