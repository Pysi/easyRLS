function POINTS = getbboxes(F, m, layers)
%getbboxes prompts gui to get bboxes or load previous from drift

Focused.mkdir(F, 'Drift', true);

try
    load(fullfile(F.dir('Drift'), 'DriftPoints.mat'), 'POINTS');
    disp('point loaded')
catch
    disp('creating new set of points')
    POINTS = cell(m.z,1);
end

for z = layers % for each z of interest
    f = imshow(m(:,:,z,F.Analysis.RefIndex), [400 800]);
    plotPreviousRegion(f, POINTS{z})
    
    try
        roi = imrect;
        wait(roi);
        pos = getPosition(roi);
        bbox = [round(pos(1)) round(pos(1) + pos(3)) ...
        round(pos(2))  round(pos(2) + pos(4))];

        Y = bbox(1):bbox(2);
        X = bbox(3):bbox(4);
        Ref = NT.Image(m(X,Y,z,F.Analysis.RefIndex));
        POINTS{z} = struct('X', X, 'Y', Y, 'Ref', Ref);
    catch ME
        fprintf('no region drawn for layer %d\n', z);
    end
end
close gcf

% save points
save(fullfile(F.dir('Drift'), 'DriftPoints.mat'), 'POINTS');

end

function plotPreviousRegion(h, pz)
% plot existing regions if exist
    try
        h.CData(pz.X, pz.Y) = h.CData(pz.X, pz.Y) + 200;
    catch
    end
end