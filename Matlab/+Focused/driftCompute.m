function driftCompute(F, method, layers)
%+Focused version of driftCompute
% kind: barycenter, globalXcorr, localXcorr

    % default layers
    if ~exist('layers', 'var')
        layers = F.Analysis.Layers;
    end
    
    % create wrapper object
    m = adapted4DMatrix(F,'source');

    switch method
        case 'globalXcorr'
            getbboxes(F, m, layers);
            driftCompute(F, m, layers);
            % driftPlotAndSave(F);
        case 'barycenter'
            driftComputeBarycentre(F, m);
        case 'localXcorr'
            driftComputeLocalXcorr(F, m);
        case 'consecutive'
            driftComputeConsecutive(F, m);
            % get point and fast and slow
        case 'fast'
            F.Analysis.drift.boxSize = 80;
            modifyRegions(F,m,layers);
            driftFast(F, m, layers);
        case 'slow'
            driftSlow(F, m, layers);
            driftPlotAndSave(F);
        case 'both'
            F.Analysis.drift.boxSize = 128;
            driftFast(F,m,layers);
            driftSlow(F,m,layers);
            driftPlotAndSave(F);
        case 'getPoints'
            getPoints(F, m);
        otherwise
            fprintf("%s not implemented\n", method);
    end
    
end

function driftPlotAndSave(F)
    showDrift(F,'x'); saveas(gcf, fullfile(F.dir('Drift'), 'dx.png'));
    showDrift(F,'y'); saveas(gcf, fullfile(F.dir('Drift'), 'dy.png'));
end