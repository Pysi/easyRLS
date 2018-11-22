function driftCompute(F, m, layers)
% computes drift by Xcorr with ref index image

    % load existing dx and dy or create new
    try 
        load(fullfile(F.dir('Drift'), 'Drifts.mat'), 'dx', 'dy');
    catch
        dx = zeros(F.param.NLayers, m.t);
        dy = zeros(F.param.NLayers, m.t);
    end

    % load ROIs
    load(fullfile(F.dir('Drift'), 'DriftPoints.mat'), 'POINTS');

    % loop
    for t = m.T
        if ~mod(t,100); fprintf("%d\n", t); end
        for z = layers    
            [dx(z,t), dy(z,t)] = POINTS{z}.Ref.fcorr( m(POINTS{z}.X, POINTS{z}.Y, z, t ) );
        end
    end
       
    % save bbox and drifts
    Focused.mkdir(F, 'Drift', true);
    save(fullfile(F.dir('Drift'), 'Drifts.mat'), 'dx', 'dy');

end
