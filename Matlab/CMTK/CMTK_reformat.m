function CMTK_reformat(ref, mov, out, transformation)
%CMTK_reformat calls cmtk

    % disp
    disp("reformating with arguments:")

    % creates the command args
    tool = "cmtk reformatx";
    options = join([
        ""
        ]);
    verbose = '-v';
    output = ['-o ' escape(out)];

    % concantenate args
    args = [tool options verbose output "--floating" escape(mov) escape(ref) escape(transformation)];

    % displays args
    disp(args')

    % makes the command
    command = join(args, " ");

    % call system command
    % command example
    % cmtk reformatx -o corr.nrrd --floating mov.nhdr ref.nhdr trans.xform/
    unix(command, '-echo');
    disp('END');

end