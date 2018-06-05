function [centerCoord, neuronShape, CD] = segmentNeuron(Img, Mask, nuc)
%segmentNeuron returns the list of the center coordinates and the list of
%the pixels belonging to the neuron
% it is "copy and paste" from the Raphael's script

Img=double(Img); % cast to double
Mask=logical(Mask); % cast to logical

assert( min(size(Img) == size(Mask)) ); % assert image and mask have the same size
% or could add auto mask :
% fprintf('computing mask ...');
% tic 
% Mask = imfill((stdfilt(Img, ones(dmask-1)) >= dmask/2), 'holes');
% Mask = imerode(Mask, ones(dmask/2));
% fprintf(' %.02f sec\n', toc);

% parameters
Nuc = nuc;                  % true for nuclear lines
sizeRange = [3 150];        % Size filter (pixels)
thCorr = 0.05;              % Correlation filter

% slient
 %#ok<*NASGU> (some values are not used)
 %#ok<*UNRCH> (Nuc prevents from reaching certain sections)

% --- Pre-process ---------------------------------------------------------

    fprintf('Pre-process ...');
    tic

    A = ordfilt2(Img, 5, ones(10));
    B = ordfilt2(Img, 95, ones(10));

    if Nuc
%         % Remove the dark parts of the brain (Geoffrey)
%         Img(Img < mean2(Img)/1.5) = 0;
%         while ok == 0
%             Img_cor = Img;
%             promt = 'Set the threshold value (0 to 1): '
%             t = input(promt)
%             T = adaptthresh(Img,t);
%             Imgbin = imbinarize(Img,T);
%             Img_cor(Imgbin == 0) = 0;
%             imshow(cat(3, Img, Img_cor, Img));
%             prompt = 'The pink parts will be set to 0, is it ok (0 = No, 1 = Ok)? '
%             ok = input(prompt)
%         end
%         
%         Img = Img_cor;
        Pre = (B-Img)./(B-A);
    else
        Pre = (Img-A)./(B-A);
    end

    fprintf(' %.02f sec\n', toc);


% --- Watershed -----------------------------------------------------------

    fprintf('Watershed\n');

    fprintf('\tPreparation ...');
    tic

    % Prepare for watershed
    Wat = Pre;
    Wat(~Mask) = Inf;

    fprintf(' %.02f sec\n', toc);

    fprintf('\tComputing ...');
    tic

    L = watershed(Wat);

    fprintf(' %.02f sec\n', toc);

    fprintf('\tPost-process .');
    tic

    R = regionprops(L, {'Centroid', 'Area', 'PixelIdxList'});

    Pos = reshape([R(:).Centroid], [2 numel(R)])';
    Area = [R(:).Area];
    Plist = {R(:).PixelIdxList};

    fprintf(' %.02f sec\n', toc);

% --- Filters -------------------------------------------------------------
            
    fprintf('Filtering\n');

    pos = Pos;
    area = Area;
    plist = Plist;

    % --- Mask

    fprintf('\tMask ...');
    tic

    I = Mask(sub2ind(size(Img), round(pos(:,2)), round(pos(:,1))));

    area = area(I);
    pos = pos(I,:);
    plist = plist(I);

    fprintf(' %.02f sec\n', toc);

    % --- Size range

    fprintf('\tSize ...');
    tic

    I = area>=sizeRange(1) & area<=sizeRange(2);
    area = area(I);
    pos = pos(I,:);
    plist = plist(I);

    fprintf(' %.02f sec\n', toc);

    % --- Correlation

    fprintf('\tCorrelation .');
    tic

    Raw = zeros(size(Img));
    Raw(sub2ind(size(Img), round(pos(:,2)), round(pos(:,1)))) = 1;

    if Nuc
        Res = -bwdist(Raw);
    else
        Res = bwdist(Raw);
    end

    w = 3;

    coeff = NaN(size(pos,1), 1);

    for i = 1:size(pos,1)

        x = round(pos(i,1));
        y = round(pos(i,2));

        Sub = Img(max(y-w,1):min(y+w, size(Img,1)), max(x-w,1):min(x+w, size(Img,2)));
        Sub2 = Res(max(y-w,1):min(y+w, size(Img,1)), max(x-w,1):min(x+w, size(Img,2)));

        coeff(i) = corr2(Sub, Sub2);

        if ~mod(i, round(size(pos,1)/10)), fprintf('.'); end

    end

    I = coeff>=thCorr;
    coeff = coeff(I);
    area = area(I);
    pos = pos(I,:);
    plist = plist(I);

    fprintf(' %.02f sec\n', toc);
        
% --- Shape extraction ----------------------------------------------------
    
    fprintf('Shape extraction\n');
    
    fprintf('\tWatershed ...');
    tic
    
    Raw = zeros(size(Img));
    Raw(sub2ind(size(Img), round(pos(:,2)), round(pos(:,1)))) = 1;
    Wat = bwdist(Raw);
    L = watershed(Wat);
    
    R = regionprops(L, {'Centroid', 'Area', 'PixelIdxList'});
    
    pos = reshape([R(:).Centroid], [2 numel(R)])';
    area = [R(:).Area];
    plist = {R(:).PixelIdxList};
    
    fprintf(' %.02f sec\n', toc);
    
    fprintf('\tMask ...');
    tic
    
    I = Mask(sub2ind(size(Img), round(pos(:,2)), round(pos(:,1))));
    
    area = area(I);
    pos = pos(I,:);
    plist = plist(I);
    
    fprintf(' %.02f sec\n', toc);
    
    fprintf('\tSize ...');
    tic
    
    I = area>=sizeRange(1) & area<=sizeRange(2);
    area = area(I);
    pos = pos(I,:);
    plist = plist(I);
    
    fprintf(' %.02f sec\n', toc);   
    
% --- Output --------------------------------------------------------------
    
     centerCoord = pos;
     neuronShape = plist;

% --- Display -------------------------------------------------------------
    Resc = (Img-min(Img(:)))/(max(Img(:))-min(Img(:)));
    Grid = ones(size(Img))*0.8;
    for i = 1:numel(plist)
        Grid(plist{i}) = 1;
    end
    CD = cat(3, Resc, Resc.*Grid, Resc);  
    
end