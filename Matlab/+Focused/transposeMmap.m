function transposeMmap(F, inMode, outMode)
% focused transposeMmap calls transposeMmap
% F focus
% inMode 'yxzlpi' 
% outMode 'xyzras'

%the modes are six character long : 1st 2nd 3rd dimension and x, y, z orientations

	% default values
	invertXY = false;
	invertX = false;
	invertY = false;
	invertZ = false;


	fprintf('performing :\n');

	if strcmp(inMode(1:2), 'yx') && strcmp(outMode(1:2), 'xy')
		invertXY = true;
		fprintf('x-y transposition\n');
	end

	if inMode(4) ~= outMode(4)
		invertX = true;
		fprintf('x inversion\n');
	end
	if inMode(5) ~= outMode(5)
		invertY = true;
		fprintf('y inversion\n');
	end
	if inMode(6) ~= outMode(6)
		invertZ = true;
		fprintf('z inversion\n');
	end

	% calling transpose
	inputFile = fullfile(F.dir.files, 'raw');
	outputFile = fullfile(F.dir.files, 'rawRAS');
	transposeMmap(inputFile, outputFile, invertXY, invertX, invertY, invertZ)

end

