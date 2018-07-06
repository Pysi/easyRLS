function dispRealCoordinates(F, tag, cursor_info, z)
% when viewing data in stack viewer, the cursor info is not the good

switch tag
    case {'corrected'}
        m = Focused.Mmap(F, tag);
        x = m.x; y = m.y;
    case {'BaselinePixel'}
        load(fullfile(F.dir(tag), [num2str(z, '%02d') '.mat']), 'indices', 'x', 'y');
    case {'BaselineNeuron'}
        load(fullfile(F.dir(tag), [num2str(z, '%02d') '.mat']), 'neuronShape', 'x', 'y');
    otherwise
        error('%s not implemented', tag);
end

cx = cursor_info.Position(1);
cy = cursor_info.Position(2);
ind = sub2ind([x y], cy, cx);

fprintf("cursor info:\n\t x = %d y = %d\n", cx, cy);
fprintf("in imageJ:\n\t x = %d y = %d\n", x-cx, y-cy);
fprintf("in Matlab:\n\t x = %d y = %d\n", cx, y-cy+1);
fprintf("linear indexing :\n\t index = %d\n", ind);

if exist('indices', 'var')
    mmapind = find(indices==ind);
    fprintf("position in mmap:\n\t index = %d\n", mmapind);
end

if exist('neuronShape', 'var')
    n = length(neuronShape);
    mask = false([1,n]);
    for i = 1:n
        if ismember(ind, neuronShape{i})
            mask(i) = true;
            break
        end
    end
    neuron = find(mask);
    fprintf("neuron number:\n\t index = %d\n", neuron);
end

end