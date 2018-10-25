function driftComputeBarycentre(F, m)
% computes drift using barycentre of isolated neurons

F.Analysis.drift.maxDrift = 8;
F.Analysis.drift.threshold = 490;

% creates dir
Focused.mkdir(F, 'Drift', true);

% returns points chosen by user (or already chosen)
% POINTS{z}(i) is a struct containing X, Y, x, y
POINTS = getPoints(F, m);

% init drift vectors (layers × t)
dx = zeros(F.param.NLayers, m.t);
dy = zeros(F.param.NLayers, m.t);

for t = m.T % along t
    disp(t);
    for z = m.Z % along z
        [dxi, dyi] = getDriftBarycentre(F, m, z, t, POINTS);
        dx(z,t) = dxi;
        dy(z,t) = dyi;
    end
end

 % save drifts
save(fullfile(F.dir('Drift'), 'Drifts.mat'), 'dx', 'dy');

end
            