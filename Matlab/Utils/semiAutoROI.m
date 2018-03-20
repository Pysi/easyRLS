function semiAutoROI(F, Z, t)
% semiAutoROI lets you modify an automatic ROI

m = Focused.Mmap(F, 'corrected'); % get the memory map

try % try to load existing mask.mat
    disp('found mask file, loading it')
    load(fullfile(F.dir.IP, 'mask.mat'), 'mask'); % get the mask
catch % if no mask variable to load, initialize to NaN
    disp('creating new mask file')
    mask = NaN(m.x,m.y,20); % default total number of layers
end

for z = Z % for each layer of concern
    
    img = m(:,:,z,t); % load image
    tmp2 = mask(:,:,z); % load mask layer
    
    % show layer
    hold off; imshow(equalize_histogram(img));
    
    if isnan( max(max( tmp2 )) ) % if mask layer is not yet defined 
        % autocompute mask (TODO add slider)
        
        % Auto brain countour (Geoffrey)
        bg_img = mean2(img);
        H = fspecial('disk',20);
        tmp1 = imfilter(img,H,'replicate');
        tmp2 = img*0;
        tmp2(tmp1>bg_img*(1-(0.005*z))) = 1;
        tmp2 = bwareaopen(tmp2,(size(img,1)*size(img,2))/4);  
    end
    
    % plot contour over this
    hold on; contour(tmp2);

    % get new contour
    tmp2 = editContour(tmp2);
    
    % stores it in 'mask' variable and saves it
    mask(:,:,z) = tmp2;
    save(fullfile(F.dir.IP, 'mask.mat'), 'mask'); % overwrites the mask
    fprintf('saved layer %d\n', z);
    
end

% pause and close current figure
pause(1); close gcf;


end


function newContour = editContour(oldContour)
% getContour lets manually edit the contour

    tmp2 = oldContour;

    [B, ~] = bwboundaries(tmp2,'noholes');
    boundary = B{1};
    boundary = boundary(1:100:end, :); % reduce the number of points by 100
    for k = 1:length(B)
        plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
    end
    poly = impoly(gca, [boundary(:,2) boundary(:,1)]);


    boundary_2 = poly.wait;
    BW = poly2mask(boundary_2(:,1), boundary_2(:,2), size(tmp2,1), size(tmp2,2));

    contour(BW)

    newContour = BW;

end
