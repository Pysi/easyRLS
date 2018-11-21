function driftFast(F, m, layers)
%driftFast recomputes cumulative sum of drift between two consecutive frames

F.Analysis.drift.frameDelay = 1;

% load existing points or create
try
    load(fullfile(F.dir('Drift'), 'DriftPoints.mat'), 'POINTS');
catch
    POINTS = getPoints(F, m);
end

% load existing dx and dy or create new
try 
    load(fullfile(F.dir('Drift'), 'Drifts.mat'), 'dx', 'dy');
catch
    dx = zeros(F.param.NLayers, m.t);
    dy = zeros(F.param.NLayers, m.t);
end
    

disp('computing fast drift')
for t = m.T % along t
    if ~mod(t,100); fprintf("%d\n", t); end
    for z = layers % along z
        [dxi, dyi] = getDriftsCum(F, m, z, t, POINTS, @getDrift);
        dx(z,t) = dxi;
        dy(z,t) = dyi;
    end
end

% corrects
for z = layers
    dx(z,:) = dx(z,:)+0.5;
    dy(z,:) = dy(z,:)+0.5;

    dx(z,:) = cumsum(dx(z,:), 2);
    dy(z,:) = cumsum(dy(z,:), 2);
end

% saves new drift
save(fullfile(F.dir('Drift'), 'Drifts.mat'), 'dx', 'dy');

end
            
function [dx, dy] = getDrift(F, img, refimg)
% returns drift for one point
nt_img = NT.Image(double(img));
nt_ref = NT.Image(double(refimg));
[dx, dy] = nt_ref.fcorr(nt_img);
end
