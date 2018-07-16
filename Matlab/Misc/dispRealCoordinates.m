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
SIZE_x = x;
SIZE_y = y;

% position of cursor in naturally oriented image
CUR_x = cursor_info.Position(1);
CUR_y = cursor_info.Position(2);

% position in a matlab matrix
POS_x = CUR_x ;
POS_y = SIZE_y - CUR_y + 1;

% linear indexing in matlab
ind = sub2ind([SIZE_x SIZE_y], POS_x, POS_y);

fprintf("cursor info:\n\t x = %d y = %d\n", CUR_x, CUR_y);
fprintf("in imageJ:\n\t x = %d y = %d\n", SIZE_x - CUR_x, SIZE_y - CUR_y);
fprintf("in Matlab:\n\t x = %d y = %d\n", POS_x, POS_y);
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