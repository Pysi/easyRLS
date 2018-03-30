function functionList = getTransformation(inMode, outMode)
%getFunctions returns a list of functions (permute and flip) adapted to the
%input mode (1D, 2D, 3D or 4D) using letters [rlapsit]

    % inits
    EM = sprintf('!!!\nModes not compatible:\ninMode = %s, outMode = %s\n!!!', inMode, outMode);
    assert(length(inMode) == length(outMode), EM); % to be sure that 'in' and 'out' have the same dimension
    inMode = upper(inMode); % work on upper case
    outMode = upper(outMode); % work on upper case
    ndim = length(inMode); % dimension (between 1 and 4)
    %#ok<*AGROW>

    % gets the new order
    order = [];
    for i = 1:ndim
        order(end+1) = findPos(outMode, dimName(inMode(i))); % number between 1 and ndim
    end

    % gets the inversions
    inversions = [];
    for i = 1:ndim
        inversions(end+1) = (inMode(order(i)) ~= outMode(i)); % true or false 
    end

    % get functions
    functionList = {};
    functionList{end+1} = ...
        @(X) permute(X, order); % permutation
    for i = 1:ndim
        if inversions(i)
            functionList{end+1} = ...
                @(X) flip(X, i); % flip
        end    
    end

    function dimensionName =  dimName(char)
    % gets the dimension name (ex: 'R' is 'x')
        dimensionName = ' ';
        switch upper(char)
            case {'R', 'L'}
                dimensionName = 'x';
                return
            case {'A', 'P'}
                dimensionName = 'y';
                return
            case {'S', 'I'}
                dimensionName = 'z';
                return
            case 'T'
                dimensionName = 't';
                return
        end
    end

    function position = findPos(mode, dim)
    %findpos returns the position of the given dimension (x, y, z) in the given mode
        % position function
        findc = @(in, c) find(~(in-c)); % finds a character in the inMode
        findm = @(in, c1, c2) [findc(in, c1) findc(in, c2)]; % finds a mode (finds whether c1 or c2 if exist)
        mode = upper(mode);
        switch dim
            case 'x'
            position = findm(mode, 'L', 'R');
            return
            case 'y'
            position = findm(mode, 'P', 'A');
            return
            case 'z'
            position = findm(mode, 'I', 'S');   
            return  
            case 't'
            position = findc(mode, 'T');   
            return   
        end
    end

end