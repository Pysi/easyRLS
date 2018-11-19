function region = getRegion(m, z, t, boxSize, region)
% expand region if given

pass = 0;
figure;
h = imshow(m(:,:,z,t), [300 1000]);
while ~pass % while adding points
    h.CData = m(:,:,z,t); % refresh view
    plotRegions(h, region); % plot all modified regions
    try % try to get point, else pass
        [y,x] = ginput(1);
        X = floor(x-boxSize):floor(x+boxSize);
        Y = floor(y-boxSize):floor(y+boxSize);
        region = append(region, struct(...
            'X', X, 'Y', Y, 'x', x, 'y', y));
    catch ME
        if strcmp(ME.identifier, 'MATLAB:ginput:FigureDeletionPause')
            fprintf("layer %d end (%d points)\n", z, length(region));
        else
            warning(ME.message);
        end
        pass = 1;
    end
end

end
    
function region = append(region, structure)
if isempty(region)
    region = structure;
else
    region(end+1) = structure;
end
end

function plotRegions(h, region)
% plot already selected regions

    for i = 1 : length(region)
       h.CData(region(i).X, region(i).Y) = h.CData(region(i).X, region(i).Y) + 200;
    end

end