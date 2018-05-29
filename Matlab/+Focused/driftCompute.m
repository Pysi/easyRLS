function driftCompute(F)
%+Focused version of driftCompute

    % Layers = in.Results.Layers;
    RefStack = F.Analysis.RefStack;
    RefIndex = F.Analysis.RefIndex;
    RefLayers = F.Analysis.RefLayers;

    % create wrapper object
    m = adapted4DMatrix(F,'source');
    mRef = false;
    
    if RefStack % if we want to use a reference stack which is outside the stack
        mRef = Focused.Mmap(F, RefStack);
        RefIndex = false;
    end

    driftCompute(F, m, mRef, RefLayers, RefIndex);
    
end