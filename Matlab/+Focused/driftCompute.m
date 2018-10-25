function driftCompute(F, barycentre)
%+Focused version of driftCompute

    % check which version to use
    if ~exist('barycentre', 'var')
        barycentre = false;
    end

    % Layers = in.Results.Layers;
    RefStack = F.Analysis.RefStack;
    RefIndex = F.Analysis.RefIndex;
    RefLayers = NaN; %F.Analysis.RefLayers;

    % create wrapper object
    m = adapted4DMatrix(F,'source');
    mRef = false;
    
    if RefStack % if we want to use a reference stack which is outside the stack
        disp(['########## We want to use a reference stack which is outside the stack => ', RefStack, ' ##########']);
        mRef = Focused.Mmap(F, RefStack);
        RefIndex = false;
    end

    if ~barycentre
        driftCompute(F, m, mRef, RefLayers, RefIndex);
    else
        driftComputeBarycentre(F, m);
    end
    
end