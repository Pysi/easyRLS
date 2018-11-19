function modifyRegions(F, m, layers)

% load existing points
load(fullfile(F.dir('Drift'), 'DriftPoints.mat'), 'POINTS');

% replace regions for given layers
for z = layers
    POINTS{z} = getRegion(m, z, F.Analysis.RefIndex, F.Analysis.drift.boxSize, []);
end

% save new regions
save(fullfile(F.dir('Drift'), 'DriftPoints.mat'), 'POINTS');