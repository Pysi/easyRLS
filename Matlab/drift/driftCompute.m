function driftCompute(F, m, mRef, RefLayers, RefIndex)
%driftCompute(F [,kwargs]) computes the drift on the given layer against the given reference stack max projection
% using the parabolic fft based drift correction
% F is the focus
% m is the 4D matrix
% ref is a 3D matrix or false
% RefLayers value
% RefIndex value or false

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%  Attention : driftCompute                                 %
%  - utilisation du max des layers selectionnés             %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

% --- manage case of reference stack
if mRef~=false % if reference stack wanted
    RefIndex = 1;
else % take it from m
    mRef=m;
end

% --- Define reference image ---
% the reference image we take is the maximum of the selected layers along
% the 3rd dimension

bbox = F.Analysis.DriftBox; % define bounding box to look into
% --- Select ROI for drift correction ---
%         disp('Please select ROI for drift correction')
%         roi = imrect;
%         wait(roi);
%         pos = getPosition(roi);
%         bbox = [round(pos(1))  round(pos(1) + pos(3)) ...
%             round(pos(2))  round(pos(2) + pos(4))];
%         Ref.region(bbox);

X = bbox(1):bbox(2);
Y = bbox(3):bbox(4);

% compute reference image with max and loads it in Raphael's image object
Ref = NT.Image(max( mRef(X,Y, RefLayers, RefIndex) ,[],3));
% display it
refIm = figure;
imagesc(Ref.pix);
axis equal

% --- Drift correction ---
% creates a figure to plot the drift correction
seeDrift = figure; hold on;
title([F.name '   dx=red, dy=green']);

% init drift vectors
dx = zeros(1,m.t);
dy = zeros(1,m.t);

for t = m.T % run across the times
    % compute the image to compare with the ref image
    Img = NT.Image( max( m(X,Y,RefLayers,t) ,[],3) );
    
    % compute the DX and DY with the Fourier transform
    [dx(t), dy(t)] = Ref.fcorr(Img);
    
    % plot 1/50 figures
    NN = 500;
    if ~mod(t,NN)
        try
            figure(seeDrift);
        catch
            error('killing the figure stops the computation');
        end
        plot(t-(NN-1):t,dx(t-(NN-1):t),'r.');
        plot(t-(NN-1):t,dy(t-(NN-1):t),'g.');
        pause(0.01);
    end   
end

% --- Save ---
% save bbox and drifts
Focused.mkdir(F, 'Drift');
save(fullfile(F.dir('Drift'), 'DriftBox.mat'), 'bbox');
save(fullfile(F.dir('Drift'), 'Drifts.mat'), 'dx', 'dy');
savefig(fullfile(F.dir('Drift'), 'driftCorrection.fig'));

close(seeDrift);
close(refIm);

end

