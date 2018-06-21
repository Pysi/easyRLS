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
sizeRange2 = [3 150];        % Size filter (pixels)

thCorr = 0.05;              % Correlation filter
thIntensity = 0;            % intensity filter VB



algorithm = 'RC'   % VB or RC
switch algorithm
    case 'VB'
        
% Parameters for algorith VB
thIntensity = 10;
sizeRange = [3 150];        % Size filter (pixels)
ecc_th = 1;
thCorr = -1;

            %% dublicate image 
            im = Img;

            %% H-minimum transform
            im = imhmin(im,2,8);
            s=30
%             figure
%             imshowpair(Img*s,im*s,'montage')

            %% morphological gradient
            I=im;
            n = 3 ;
            se = strel(ones(n,n));

            N = 8; R = 2;
            se = strel('disk',R,N)

            im = imdilate(I, se) - imerode(I, se);
%             figure
%             imshowpair(Img*s,im*s,'montage')
            %% Apply Mask
            im(~Mask) = 0;

            %% H-minimum transform
            im = imhmin(im,15,8);
            

            %% watershed
            L = watershed(im,4);
            R = regionprops(L,Img, {'Centroid', 'Area', 'PixelIdxList','Eccentricity','MinIntensity'});
            [Pcont, L] = bwboundaries(L,4,'noholes');
            Pcont = cellfun( @(x) flipdim(x,2), Pcont, 'UniformOutput', false );
            Pos = reshape([R(:).Centroid], [2 numel(R)])';
            Area = [R(:).Area];
            Plist = {R(:).PixelIdxList};
            Ecc = [R.Eccentricity];
            MeanInt = [R(:).MinIntensity];

            Resc = (Img-min(Img(:)))/(max(Img(:))-min(Img(:))) ;
            Grid = ones(size(I))*0.1;
            for i = 1:numel(Plist)
                Grid(Plist{i}) = 1;
            end
            CD = cat(3, Resc, Resc.*Grid, Resc);  

%             figure
%             scatter(Pos(:,1),-Pos(:,2),Pos(:,1)*0+100)
% 
%             figure
%             imshowpair(Img,CD,'montage')

            %%

            plist = Plist;
            area = Area;
            pos = Pos;
            ecc = Ecc;
            meanInt = MeanInt;

           
            %% --- Size range

            fprintf('\tSize ...');
            tic

            I = area>=sizeRange(1) & area<=sizeRange(2);
            area = area(I);
            pos = pos(I,:);
            ecc = ecc(I);
            plist = plist(I);
            meanInt = meanInt(I);


            fprintf(' %.02f sec\n', toc);

            %% --- Excentricity
            clear I
            I = ecc<=ecc_th;

            area = area(I);
            pos = pos(I,:);
            ecc = ecc(I);
            plist = plist(I);
            meanInt = meanInt(I);

            %% --- Correlation with mean intensity profile 
            Nuc = 1
            clear I
                fprintf('\tCorrelation .');
                tic

                w = 5;

                coeff = NaN(size(pos,1), 1);
                Sub = zeros(2*w+1,2*w+1);
                N=0;
                for i = 1:size(pos,1)

                    x = round(pos(i,1));
                    y = round(pos(i,2));
                    if ( y-w >=1 & y+w <= size(Img,1) & x-w >=1 & x+w <=size(Img,2) )
                            Sub = Sub + Img(max(y-w,1):min(y+w, size(Img,1)), max(x-w,1):min(x+w, size(Img,2)));

                            N=N+1;
                    end
                end
                meanSub = Sub/N;
                Sub = zeros(2*w+1,2*w+1);

%                 figure;surface(meanSub)
               
                N=0
                for i = 1:size(pos,1)
                    x = round(pos(i,1));
                    y = round(pos(i,2));

                    if ( y-w >=1 & y+w <= size(Img,1) & x-w >=1 & x+w <=size(Img,2) )
                        Sub = Img(max(y-w,1):min(y+w, size(Img,1)), max(x-w,1):min(x+w, size(Img,2)));
                        coeff(i) = corr2(meanSub, Sub);
                        N=N+1;
                    end

                    if ~mod(i, round(size(pos,1)/10)), fprintf('.'); end

                end

                I = coeff>=thCorr ;%& coeff<=thCorr;
                coeff = coeff(I);
                area = area(I);
                pos = pos(I,:);
                ecc = ecc(I);
                plist = plist(I);
                meanInt = meanInt(I);


                fprintf(' %.02f sec\n', toc);
                %% --- intensity filter
                fprintf('\tIntensity filter ...');
                tic

                I = meanInt>=thIntensity;
                area = area(I);
                pos = pos(I,:);
                ecc = ecc(I);
                plist = plist(I);
                meanInt = meanInt(I);

                fprintf(' %.02f sec\n', toc);
%                 
%                 % --- Shape extraction ----------------------------------------------------
%     
%                 fprintf('Shape extraction\n');
% 
%                 fprintf('\tWatershed ...');
%                 tic
% 
%                 Raw = zeros(size(Img));
%                 Raw(sub2ind(size(Img), round(pos(:,2)), round(pos(:,1)))) = 1;
%                 Wat = bwdist(Raw);
%                 L = watershed(Wat);
% 
%                 R = regionprops(L, {'Centroid', 'Area', 'PixelIdxList'});
% 
%                 pos = reshape([R(:).Centroid], [2 numel(R)])';
%                 area = [R(:).Area];
%                 plist = {R(:).PixelIdxList};
% 
%                 fprintf(' %.02f sec\n', toc);
% 
%                 fprintf('\tMask ...');
%                 tic
% 
%                 I = Mask(sub2ind(size(Img), round(pos(:,2)), round(pos(:,1))));
% 
%                 area = area(I);
%                 pos = pos(I,:);
%                 plist = plist(I);
% 
%                 fprintf(' %.02f sec\n', toc);
% 
%                 fprintf('\tSize ...');
%                 tic
% 
%                 I = area>=sizeRange(1) & area<=sizeRange(2);
%                 area = area(I);
%                 pos = pos(I,:);
%                 plist = plist(I);
% 
%                 fprintf(' %.02f sec\n', toc);   


    case 'RC'

% slient
 %#ok<*NASGU> (some values are not used)
 %#ok<*UNRCH> (Nuc prevents from reaching certain sections)

% --- Pre-process ---------------------------------------------------------

    fprintf('Pre-process ...');
    tic

    A = ordfilt2(Img, 5, ones(10));
    B = ordfilt2(Img, 95, ones(10));

    if Nuc
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
    
    R = regionprops(L,Img ,{'Centroid', 'Area', 'PixelIdxList','MinIntensity'});
    
    pos = reshape([R(:).Centroid], [2 numel(R)])';
    area = [R(:).Area];
    plist = {R(:).PixelIdxList};
    meanInt = [R(:).MinIntensity];

    fprintf(' %.02f sec\n', toc);
    
    fprintf('\tMask ...');
    tic
    
       %% --- intensity filter VB
       
                fprintf('\tIntensity filter ...');
                tic

                I = meanInt>=thIntensity;
                area = area(I);
                pos = pos(I,:);
                plist = plist(I);
                meanInt = meanInt(I);

                fprintf(' %.02f sec\n', toc);
                %%
    I = Mask(sub2ind(size(Img), round(pos(:,2)), round(pos(:,1))));
    
    area = area(I);
    pos = pos(I,:);
    plist = plist(I);
    
    fprintf(' %.02f sec\n', toc);
    
    fprintf('\tSize ...');
    tic
    
    I = area>=sizeRange2(1) & area<=sizeRange2(2);
    area = area(I);
    pos = pos(I,:);
    plist = plist(I);
    
    fprintf(' %.02f sec\n', toc);   
    
       

end    
% --- Output --------------------------------------------------------------
    
     centerCoord = pos;
     neuronShape = plist;

% --- Display -------------------------------------------------------------
    Resc = (Img-min(Img(:)))/(max(Img(:))-min(Img(:)));
    Grid = ones(size(Img))*0.8;
    for i = 1:numel(plist)
        Grid(plist{i}) = 1;
    end
    
%         Grid = ones(size(Img))*0;
% 
%      for i = 1:numel(Pcont)
%         Grid(Pcont{i}) = 255;
%     end
%         boundaries = L == 0;
%     tmp = Resc*0;
%     tmp(boundaries) = 255;
  %  figure;imshow(tmp)
    CD = cat(3, Resc, Resc.*Grid, Resc);  

  %  CD = cat(3, Resc, Resc + Grid, Resc);  
    
end