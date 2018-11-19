function POINTS = getPoints(F, m)
%getPoints prompts gui to get points or load previous from drift

boxSize = F.Analysis.drift.boxSize;
% threshold = F.Analysis.drift.threshold;

Focused.mkdir(F, 'Drift', true);

try
    load(fullfile(F.dir('Drift'), 'DriftPoints.mat'), 'POINTS');
    disp('point loaded')
catch
    disp('creating new set of points')
    POINTS = cell(10,1);
end

t = F.Analysis.RefIndex;
for z = m.Z % for each z
    POINTS{z} = getRegion(m, z, t, boxSize, POINTS{z});
end

% save points
save(fullfile(F.dir('Drift'), 'DriftPoints.mat'), 'POINTS');

end