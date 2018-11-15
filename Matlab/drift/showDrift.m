function showDrift(F, d)

figure; hold on;

for i = F.Analysis.Layers
    plot(d(i,:));
%     plot(smooth(d(i,:), 30))
end