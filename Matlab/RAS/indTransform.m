function NewLinInd = indTransform(LinInd, sizes, inversions, order)
%indTransform transforms linear indexing according to inversions and order
% LinInd are the linear indices
% sizes are the size of each dimension (in the given order)
% inversions are the inversions along each dimension (in the given order)
% order is the permutation of dimensions

    dim = length(sizes);
    
    oldSizes(order) = sizes; % NOT SURE WHY IT WORKS ! TODO VERIFY IN WIDER CONTEXT (write tests)

    switch dim
        case 2
            [i, j] = ind2sub(sizes, LinInd);
            Subs = {i, j};
        case 3
            [i, j, k] = ind2sub(sizes, LinInd);
            Subs = {i, j, k};
        case 4
            [i, j, k, l] = ind2sub(sizes, LinInd);
            Subs = {i, j, k, l};
        otherwise
            error('Matlab did not implement ind2sub and sub2ind for an unknown dimension');
    end

    NewSubs = subTransform(Subs, oldSizes, inversions, order);

    switch dim
        case 2
            NewLinInd = sub2ind(oldSizes, NewSubs{1}, NewSubs{2});
        case 3
            NewLinInd = sub2ind(oldSizes, NewSubs{1}, NewSubs{2}, NewSubs{3});
        case 4
            NewLinInd = sub2ind(oldSizes, NewSubs{1}, NewSubs{2}, NewSubs{3}, NewSubs{4});
    end

end