function POINTS = getPoints(F, m)
%getPoints prompts gui to get points or load previous from drift

maxDrift = F.Analysis.drift.maxDrift;
threshold = F.Analysis.drift.threshold;

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
    f = figure;
    imshow(m(:,:,z,t), [300 2000]);
    plotRegions(f, POINTS{z});
    while ~pass % while adding points
        try % try to get point, else pass
            try % try to get POINT{z} size, else create
                l = length(POINTS{z});
            catch
                l = 0;
            end
            [y,x] = ginput(1);
            X = floor(x-maxDrift):floor(x+maxDrift);
            Y = floor(y-maxDrift):floor(y+maxDrift);
            img = m(X,Y,z,t);
            [x,y] = centerOfMass(img, threshold);
            POINTS{z}(l+1) = struct(...
                'X', X, 'Y', Y, 'x', x, 'y', y);
        catch ME
            if ME.identifier == 'MATLAB:ginput:FigureDeletionPause'
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

function plotRegions(f, Pz)
% plot already selected regions

figure(f);



end