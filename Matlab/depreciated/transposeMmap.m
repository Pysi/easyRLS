function transposeMmap(inputFile, outputFile, inMode, outMode)
%transposeMmap creates a new stack
%inputFile input file (without extension)
%outputFile output file (without extension)
%invertXY if true transpose
%invertX, invertY, invertZ booleans
%
% x-axis (first dimension) is right-left axis
% y-axis (second dimension) is anterio-posterior axis
% z-axis (third dimension) is superior-inferior axis
% t-axis (fourth dimension) is after-before causality time axis
%

[invertXY, invertX, invertY, invertZ] = defInvert(inMode, outMode);
    
	% get Mmap
	m = Mmap(inputFile);    
    % the lower altitude must be the first in binary file
    if invertZ
        Z = flip(m.Z);
    else
        Z = m.Z; 
    end
    % defines x and y
    if invertXY
        x = m.y;
        y = m.x;
    else
        x = m.x;
        y = m.y;
    end
    T = m.T;
		    
	% open in write binary mode
	fid = fopen([outputFile '.bin'], 'wb');
    w = waitbar(0, 'transposing file to RAS');
    
	% loop over images
    for t = T % along time
        waitbar(t/m.t)
        for z = Z % along z
	        Img = m(:,:,z,t);
	        Img = transposeImage(Img, invertXY, invertX, invertY);
            
            fwrite(fid, Img, 'uint16');
        end
    end	
	
	close(w)
	fclose(fid);

    z = m.z; %#ok<*NASGU>
    t = m.t; % (could be useless)
    
    save([outputFile '.mat'], 'x', 'y', 'z', 't', 'Z', 'T');
end

