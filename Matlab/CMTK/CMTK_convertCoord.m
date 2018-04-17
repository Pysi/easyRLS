function outCoord = CMTK_convertCoord(inCoord, transformation)
%CMTK_convertCoord takes a n×3 coordinates vector and applies the
%transformation

    % disp
    disp("converting coordinates")
    
    %returns a string with triplets separated by \n
    asciiCoord = join(join(string(inCoord)),"\n");
    fid = fopen('/tmp/asciicoordinates.txt', 'w');
    fprintf(fid, asciiCoord);
    fclose(fid);
    
    % creates the command args
    echo = "cat /tmp/asciicoordinates.txt";
    tool = "cmtk streamxform";
    options = join([
        ""
        ]);
    verbose = "";

    % concantenate args
    args = [echo "|" tool options verbose "-- --inverse" escape(transformation)];
    
    % makes the command
    command = join(args, " ");
    
    % call system command
    [~,cmdout] = unix(command');
    C = textscan(cmdout, '%f %f %f');
    outCoord = cell2mat(C);
    delete('/tmp/asciicoordinates.txt');
    disp('END');

end