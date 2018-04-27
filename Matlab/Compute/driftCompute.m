function driftCompute(F, kwargs)
%driftCompute computes the drift on the given layer against the given reference stack max projection
% using the parabolic fft based drift correction
% F is the focus
% m is the Mmap object

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%  Attention : driftCompute contient plusieurs choix        %
%  - utilisation du max des layers selectionnés             %
%  - bbox définie dans le programme                         %
%  - enregistrement des drifts dans des dossiers séparés    %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

% create wrapper object
m = Focused.Mmap(F, 'rawRAS');
mRef = m;

% parse input to change reference stack TODO write validation function
in = inputParser;
in.addParameter('RefIndex', 10);        % by default 10th stack
in.addParameter('RefStack', '');        % by default none
in.addParameter('RefLayers', 8:10);     % by default stacks 8, 9, 10
% in.addParameter('Layers', [F.sets.id]); % by default all 1 2 3 ... 20
in.parse(kwargs{:})

% Layers = in.Results.Layers;
RefStack = in.Results.RefStack;
RefIndex = in.Results.RefIndex;
RefLayers = in.Results.RefLayers;

if RefStack % if we want to use a reference stack which is outside the stack
    mRef = Focused.Mmap(F, RefStack);
    RefIndex = 1;
end

% --- Define reference image ---
% the reference image we take is the maximum of the selected layers along
% the 3rd dimension

% --- Select ROI for drift correction ---
%         disp('Please select ROI for drift correction')
%         roi = imrect;
%         wait(roi);
%         pos = getPosition(roi);
%         bbox = [round(pos(1))  round(pos(1) + pos(3)) ...
%             round(pos(2))  round(pos(2) + pos(4))];
%         Ref.region(bbox);

bbox = [ 53 566 45 914 ]; % define bounding box to look into
X = bbox(1):bbox(2);
Y = bbox(3):bbox(4);

% compute reference image with max and loads it in Raphael's image object
Ref = NT.Image(max(mRef(X,Y, RefLayers, RefIndex),[],3));

% --- Drift correction ---
% creates a figure to plot the drift correction
figure; hold on;
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
    if ~mod(t,50)
        plot(t-49:t,dx(t-49:t),'r.');
        plot(t-49:t,dy(t-49:t),'g.');
        pause(0.01);
    end   
end

% --- Save ---
% save bbox and drifts
disp('making ''IP'' directory');
mkdir(F.dir.IP);
save(fullfile(F.dir.IP, 'DriftBox'), 'bbox');
save(fullfile(F.dir.IP, 'Drifts'), 'dx', 'dy');
savefig(fullfile(F.dir.IP, 'driftCorrection'));

close gcf

end

