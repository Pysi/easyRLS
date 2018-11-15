function POINTS = getPoints(F, m)
%getPoints prompts gui to get points or load previous from drift

boxSize = F.Analysis.drift.boxSize;
% threshold = F.Analysis.drift.threshold;

try
    load(fullfile(F.dir('Drift'), 'DriftPoints.mat'), 'POINTS');
    disp('point loaded')
catch
    disp('creating new set of points')
    POINTS = {};
end

t = F.Analysis.RefIndex;
for z = m.Z % for each z
    pass = 0;
    figure;
    h = imshow(m(:,:,z,t), [300 1000]);
    while ~pass % while adding points
        h.CData = m(:,:,z,t); % refresh view
        plotRegions(h, POINTS, z); % plot all modified regions
        try % try to get point, else pass
            l = getLength(POINTS, z);
            [y,x] = ginput(1);
            X = floor(x-boxSize):floor(x+boxSize);
            Y = floor(y-boxSize):floor(y+boxSize);
            img = m(X,Y,z,t);
%             [x,y] = centerOfMass(img, threshold);
            POINTS{z}(l+1) = struct(...
                'X', X, 'Y', Y, 'x', x, 'y', y);
        catch ME
            if strcmp(ME.identifier, 'MATLAB:ginput:FigureDeletionPause')
                fprintf("layer %d end (%d points)\n", z, l);
            else
                warning(ME.message);
            end
            pass = 1;
        end
    end
end

% save points
save(fullfile(F.dir('Drift'), 'DriftPoints.mat'), 'POINTS');

end

function l = getLength(p, z)
    try % try to get POINT{z} size, else 0
        l = length(p{z});
    catch
        l = 0;
    end
end

function plotRegions(h, p, z)
% plot already selected regions

l = getLength(p, z);

    for i = 1 : l
       h.CData(p{z}(i).X, p{z}(i).Y) = h.CData(p{z}(i).X, p{z}(i).Y) + 200;
    end

end