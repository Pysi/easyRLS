function CMTK_warp(ref, mov, out, initial)
%CMTK_warp calls cmtk

    % disp
    disp("performing nonrigid registration with arguments:")

    % creates the command args
    tool = "cmtk warp";
    init = join(["--initial" escape(initial)]);
    options = join([
        "-v"
        "--fast"
        "--grid-spacing 40"
        "--refine 2"
        "--jacobian-weight 0.001"
        "--coarsest 6.4"
        "--sampling 3.2"
        "--accuracy 3.2"
        "--omit-original-data"
        "--energy-weight 1e-1"
%         "--smoothness-constraint-weight 1e-1"
%         "--grid-refine 2"
%         "--min-stepsize 0.25"
%         "--adaptive-fix-thresh 0.25"
        ]);
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