function CMTK_affine(ref, mov, out)
%CMTK_affine calls cmtk

    % disp
    disp("performing affine registration with arguments:");

    % creates the command args
    tool = "cmtk registration";
    init = "--initxlate";
    options = join([
        "--dofs 6,9"
        "--sampling 3"
        "--coarsest 25"
        "--omit-original-data"
        "--exploration 25"
        "--accuracy 3"
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
