function POINTS = getPoints(F, m)
%getPoints prompts gui to get points or load previous from drift

boxSize = F.Analysis.drift.boxSize;

Focused.mkdir(F, 'Drift', true);

try
    load(fullfile(F.dir('Drift'), 'DriftPoints.mat'), 'POINTS');
    disp('point loaded')
catch
    disp('creating new set of points')
    POINTS = cell(m.z,1);
end

t = F.Analysis.RefIndex;
for z = F.Analysis.Layers % for each z of interest
    POINTS{z} = getRegion(m, z, t, boxSize, POINTS{z});
end

% save points
save(fullfile(F.dir('Drift'), 'DriftPoints.mat'), 'POINTS');

end