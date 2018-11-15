function [dx, dy] = getDrifts(F, m, z, t, POINTS, getDrift)
% getDrifts get drift
% for one layer, one time (all points)
% getDrift is the function used to get the drift

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
        refimg = m(...
            POINTS{z}(i).X,...
            POINTS{z}(i).Y,...
            z,...
            1);
        [driftX(i), driftY(i)] = getDrift(F, img, refimg);
    end

    % returns the mean drift
    dx = nanmean(driftX);
    dy = nanmean(driftY);
else
    dx = NaN;
    dy = NaN;
end

end