function transposeMmap(F, inMode, outMode)
% focused transposeMmap calls transposeMmap
% F focus
% inMode 'ali' 
% outMode 'ras'

	% calling transpose
	inFile = fullfile(F.dir.files, 'raw');
	outFile = fullfile(F.dir.files, 'rawRAS');
	transposeMmap(inFile, outFile, inMode, outMode)

end

