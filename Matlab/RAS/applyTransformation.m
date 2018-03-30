function OUT = applyTransformation(IN, functionList)
%applyTransformation anly applies a list of function on the input matrix
% see 'getTransformation' to see how to get the function list

    TMP = IN;

    for i = 1:length(functionList)
        TMP = functionList{i}(TMP);
    end

    OUT = TMP;

end