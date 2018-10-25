function [dx, dy] = getDriftBarycentre(F, m, z, t, POINTS)
% getDriftBarycentre get drift compared to origin stored in POINTS
% for one layer, one time (all points)

l = length(POINTS{z}); % number of points to average

if l > 0
    % init all drifts
    driftX = NaN(1, l);
    driftY = NaN(1, l);

    for i = 1:l % for each point
        img = m(...
            POINTS{z}(i).X,...
            POINTS{z}(i).Y,...
            z,...
            t);
        x0 = POINTS{z}(i).x;
        y0 = POINTS{z}(i).y;
        [driftX(i), driftY(i)] = getDrift(F, img, x0, y0);
    end

    % returns the mean drift
    dx = nanmean(driftX);
    dy = nanmean(driftY);
else
    dx = NaN;
    dy = NaN;
end

end

function [dx, dy] = getDrift(F, img, x0, y0)
% returns drift for one point
[x, y] = centerOfMass(img, F.Analysis.drift.threshold);
dx = x-x0;
dy = y-y0;
end