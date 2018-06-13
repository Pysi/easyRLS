function NewSubs = subTransform(Subs, sizes, inversions, order)
%subTransform transforms subscripts according to given inversions and order
% Subs is a cell array of subs
% sizes is the size of each dimension (in the given order)
% inversions is a logical array of inversions (in the given order)
% order is a permutation of the orders

    dim = length(sizes);

    NewSubs = Subs(order);

    % invert the axis
    for i = 1:dim
        if inversions(i)
            NewSubs{i} = sizes(i) - NewSubs{i} + 1; % invert the subscripts
        end
    end

end