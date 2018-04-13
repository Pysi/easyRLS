function CMTK_warp(ref, mov, out, initial)
%CMTK_warp calls cmtk

    % disp
    disp("performing nonrigid registration with arguments:")

    % creates the command args
    tool = "cmtk warpx --fast";
    init = join(["--initial" escape(initial)]);
    options = join([
        "--smoothness-constraint-weight 1e-1"
        "--grid-refine 2"
        "--min-stepsize 0.25"
        "--adaptive-fix-thresh 0.25"
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