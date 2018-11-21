function showDrift(F, d)

if ~exist('d', 'var')
    d = 'x';
end

% load drift if not given
if d == 'x' || d == 'y'
    load(fullfile(F.dir('Drift'), 'Drifts.mat'), 'dx', 'dy');
    if d == 'x'
        d = dx;
    end
    if d == 'y'
        d = dy;
    end
end

figure; hold on;

for i = F.Analysis.Layers
    plot(d(i,:));
%     plot(smooth(d(i,:), 30))
end