function [dx, dy] = driftSlow(F, m, layers)
%correctSlowDrift creates mini gray stacks in binned full frame and corrects dx&dy on interpolation

% load existing dx and dy or create new
try 
    load(fullfile(F.dir('Drift'), 'Drifts.mat'), 'dx', 'dy');
catch
    dx = zeros(F.param.NLayers, m.t);
    dy = zeros(F.param.NLayers, m.t);
end

% params
F.Analysis.drift.chunkSize = 64;
F.Analysis.drift.maxDrift = 10; % max drift in pixels of binned image
F.Analysis.drift.binning = 8;

chunkSize = F.Analysis.drift.chunkSize;
chunkNumber = floor(m.t/chunkSize);

binning = F.Analysis.drift.binning;
maxDrift = F.Analysis.drift.maxDrift;

% binned version
bX = 1:binning:m.x;
bY = 1:binning:m.y;
% binned and cropped version
bXc = maxDrift : length(bX) - maxDrift;
bYc = maxDrift : length(bY) - maxDrift;
% size of mini graystack
x = length(bXc);
y = length(bYc);

M = zeros(x,y,m.z,chunkNumber);
Dx = zeros(m.z, chunkNumber);
Dy = zeros(m.z, chunkNumber);

% get correction for chunks
fprintf("computing slow drift\n");
for chunk = 1:chunkNumber
    if ~mod(chunk-1, 10); fprintf("chunk: %d/%d\n", chunk, chunkNumber); end
    T = (1:chunkSize) + (chunk-1)*chunkSize; % correspondig t
    for z = layers
        for t = T
            % pre-drift correction on small images
            binned = double(m(bX,bY,z,t)); % bin
            translated = imtranslate(binned, [-dy(z,t), -dx(z,t)]./binning); % translate
            cropped = translated(bXc,bYc); % crop
            M(:,:,z,chunk) = M(:,:,z,chunk) + cropped; % sum
        end
        img = M(:,:,z,chunk);
        refimg = M(:,:,z,1);
        [Dx(z, chunk), Dy(z, chunk)] = getDrift(F, img, refimg);
    end
end


% interpolate chunks for all t
Ddx = zeros(m.z, m.t);
Ddy = zeros(m.z, m.t);

centersT = (1 : chunkSize : chunkNumber * chunkSize) + floor(chunkSize/2);
for z = F.Analysis.Layers
    Ddx(z,:) = interp1(centersT,Dx(z,:),m.T,'spline') .* binning;
    Ddy(z,:) = interp1(centersT,Dy(z,:),m.T,'spline') .* binning;
end

dx = Ddx;
dy = Ddy;

end
    

function [dx, dy] = getDrift(F, img, refimg)
% returns drift for one point
nt_img = NT.Image(double(img));
nt_ref = NT.Image(double(refimg));
[dx, dy] = nt_ref.fcorr(nt_img);
end