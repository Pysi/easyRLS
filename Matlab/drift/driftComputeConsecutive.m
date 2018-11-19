function driftComputeConsecutive(F, m)
%driftComputeConsecutive computes the drift of the (n) frame compared to the (n-1) frame on given zones

% F.Analysis.drift.maxDrift = 8;  % take even value
% F.Analysis.drift.period = 20;
F.Analysis.drift.frameDelay = 1;

% creates dir
Focused.mkdir(F, 'Drift', true);

% returns points chosen by user (or already chosen)
% POINTS{z}(i) is a struct containing X, Y, x, y
POINTS = getPoints(F, m);

% init drift vectors (layers × t)
dx = zeros(F.param.NLayers, m.t);
dy = zeros(F.param.NLayers, m.t);
disp('computing fast drift')
for t = m.T % along t
    if ~mod(t,100); fprintf("%d\n", t); end
    for z = m.Z % along z
        [dxi, dyi] = getDriftsCum(F, m, z, t, POINTS, @getDrift);
        dx(z,t) = dxi;
        dy(z,t) = dyi;
    end
end

% we got cumulative drift, real drift is cumsum
% corrects Raphaël's function bug (fft ?)
dx = dx+0.5;
dy = dy+0.5;

dx = correctN(dx, F.Analysis.drift.frameDelay);
dy = correctN(dy, F.Analysis.drift.frameDelay);

% computes slow drift
[Dx, Dy] = computeSlowDrift(F, m, dx, dy, @getDrift);

% replace drift
dx = dx + Dx;
dy = dy + Dy;

% make refindex be the reference
dx(z,:) = dx(z,:) - dx(z,F.Analysis.RefIndex);
dy(z,:) = dy(z,:) - dy(z,F.Analysis.RefIndex);

% show
showDrift(F, dx); saveas(gcf, fullfile(F.dir('Drift'), 'dx.png'));
showDrift(F, dy); saveas(gcf, fullfile(F.dir('Drift'), 'dy.png'));

save(fullfile(F.dir('Drift'), 'Drifts.mat'), 'dx', 'dy');

end
            
function [dx, dy] = getDrift(F, img, refimg)
% returns drift for one point
nt_img = NT.Image(double(img));
nt_ref = NT.Image(double(refimg));
[dx, dy] = nt_ref.fcorr(nt_img);
end



function d = correctN(d, n)
for i = 1:n
    d(:,i:n:end) = cumsum(d(:, i:n:end),2);
end
end



