function driftComputeConsecutive(F, m)
%driftComputeConsecutive computes the drift of the (n) frame compared to the (n-1) frame on given zones

F.Analysis.drift.boxSize = 48;
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

% show
showDrift(F, dx); saveas(gcf, fullfile(F.dir('Drift'), 'fast_dx.png'));
showDrift(F, dy); saveas(gcf, fullfile(F.dir('Drift'), 'fast_dy.png'));

% computes slow drift
[Dx, Dy] = computeSlowDrift(F, m, dx, dy, @getDrift);

% show
showDrift(F, Dx); saveas(gcf, fullfile(F.dir('Drift'), 'slow_dx.png'));
showDrift(F, Dy); saveas(gcf, fullfile(F.dir('Drift'), 'slow_dy.png'));

% replace drift
dx = dx + Dx;
dy = dy + Dy;

save(fullfile(F.dir('Drift'), 'Drifts.mat'), 'dx', 'dy');

end
            
function [dx, dy] = getDrift(F, img, refimg)
% returns drift for one point
nt_img = NT.Image(double(img));
nt_ref = NT.Image(double(refimg));
[dx, dy] = nt_ref.fcorr(nt_img);
end



function d = correct(d)
% correction pour n = 1
d = cumsum(d, 2);
end


function d = correctN(d, n)
for i = 1:n
    d(:,i:n:end) = cumsum(d(:, i:n:end),2);
end
end



function d = NaNToZeRo(d)
d(isnan(d))=0;
end












% OLD

% % computing slow drift
% disp('computing slow drift')
% M = NaN(F.Analysis.drift.boxSize*2+1, F.Analysis.drift.boxSize*2+1, m.z, m.t); % new mini matrix corrected from fast drift
% 
% % fills M
% disp('creating submatrix')
% for t = m.T
%     if ~mod(t,100); fprintf("%d\n", t); end
%     for z = F.Analysis.Layers
%         M(:,:,z,t) = imtranslate(...
%                              m( POINTS{z}(1).X,...
%                                 POINTS{z}(1).Y,...
%                                 z,...
%                                 t),...
%                              [-dy(z, t), -dx(z, t)]);
%     end
% end
% 
% % reduce M to avoid border effects
% disp('reducing submatrix')
% minXY = F.Analysis.drift.maxDrift / 2;
% maxXY = F.Analysis.drift.boxSize - minXY;
% M = M( minXY:maxXY, minXY:maxXY, :, :);
% 
% % moving average of M in t direction
% disp('smoothing along t')
% ker = ones(1, F.Analysis.drift.period);
% for z = F.Analysis.Layers
%     for x = 1:size(M, 1)
%         for y = 1:size(M,2)
%             M(x,y,z,:) = conv(squeeze(M(x,y,z,:)), ker, 'same');
%         end
%     end
% end
% 
% % computes drift compared to F.Analysis.RefIndex frame
% disp('computing drift on smoothed submatrix')
% for z = F.Analysis.Layers
%     Ref{z} = NT.Image(M( :,:,z, F.Analysis.RefIndex ));
% end
% for t = m.T % along t
%     if ~mod(t,100); fprintf("%d\n", t); end
%     for z = F.Analysis.Layers % along z
%         Img = M(:,:,z,t);
% 
%         % computes the dx and dy
%         [ddx, ddy] = Ref{z}.fcorr(Img);
%         
%         % corrects existing dx and dy
%         dx(z,t) = dx(z,t) + ddx;
%         dx(z,t) = dx(z,t) + ddy;
%     end
% end
% disp('updating dx and dy')

% save drifts

