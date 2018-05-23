function driftCompute(F, tag, kwargs)
%+Focused version of driftCompute

    switch nargin % check if kwargs were given
        case 2
            kwargs = {};
        case 3
    end

    % parse input to change reference stack TODO write validation function
    in = inputParser;
    in.addParameter('RefIndex', 10);        % by default 10th stack
    in.addParameter('RefStack', '');        % by default none
    in.addParameter('RefLayers', 8:10);     % by default stacks 8, 9, 10
    in.parse(kwargs{:})

    % Layers = in.Results.Layers;
    RefStack = in.Results.RefStack;
    RefIndex = in.Results.RefIndex;
    RefLayers = in.Results.RefLayers;

    % create wrapper object
    m = adapted4DMatrix(F,tag);
    mRef = false;
    
    if RefStack % if we want to use a reference stack which is outside the stack
        mRef = Focused.Mmap(F, RefStack);
        RefIndex = false;
    end

    driftCompute(F, m, mRef, RefLayers, RefIndex);
    
end