function driftComputeLocalXcorr(F, m)
%driftComputeLocalXcorr computes drift on local regions cross correlation

F.Analysis.drift.boxSize = 32;
F.Analysis.drift.threshold = 400;

% creates dir
Focused.mkdir(F, 'Drift', true);

% returns points chosen by user (or already chosen)
% POINTS{z}(i) is a struct containing X, Y, x, y
POINTS = getPoints(F, m);

% init drift vectors (layers × t)
dx = zeros(F.param.NLayers, m.t);
dy = zeros(F.param.NLayers, m.t);

for t = m.T % along t
    fprintf("%d\n", t);
    for z = m.Z % along z
        [dxi, dyi] = getDrifts(F, m, z, t, POINTS, @getDrift);
        dx(z,t) = dxi;
        dy(z,t) = dyi;
    end
end

 % save drifts
save(fullfile(F.dir('Drift'), 'Drifts.mat'), 'dx', 'dy');

end
            
function [dx, dy] = getDrift(F, img, refimg)
% returns drift for one point
nt_img = NT.Image(img - F.Analysis.drift.threshold);
nt_ref = NT.Image(refimg - F.Analysis.drift.threshold);
[dx, dy] = nt_ref.fcorr(nt_img);
end