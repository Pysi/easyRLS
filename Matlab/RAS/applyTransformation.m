function OUT = applyTransformation(IN, functionList)
%applyTransformation anly applies a list of function on the input matrix
% see 'getTransformation' to see how to get the function list

    assert( ndims(IN) == length(functionList) ) % be sure that the size is good
    ndim = ndims(IN);

    TMP = IN;

    for i = 1:ndim
        TMP = functionList{i}(TMP);
    end

    OUT = TMP;

end