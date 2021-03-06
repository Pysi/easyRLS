function CMTK_affine(ref, mov, out)
%CMTK_affine calls cmtk

    % disp
    disp("performing affine registration with arguments:");

    % creates the command args
    tool = "cmtk registration";
    init = "--initxlate";
    options = join([
        "--dofs 6,9,12"
        "--sampling 3"
        "--coarsest 25"
        "--omit-original-data"
        "--accuracy 3"
        "--exploration 25.6"
        ], " ");
    verbose = '-v';
    output = join(['-o' escape(out)]);

    % concantenate args
    args = [tool init options verbose output escape(ref) escape(mov)];

    % displays args
    disp(args')

    % makes the command
    command = join(args, " ");

    % call system command
    unix(command, '-echo');
    disp('END');

end


