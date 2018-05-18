function semiAutoROI(F, Layers, t, tag)
%semiAutoROI(F, Layers, t, tag) lets you modify an automatic ROI
% F is the current focus instance
% Layers are the layers you want to draw the contour on
% t is the time index of the reference layer
% tag could be :
%     - the tag of the binary you want to work on ('corrected' for instance)
%     - the name of a dcimg if you want to work on a dcimg (Run00.dcimg for instance)

% if the tag has an extension and that this extension is 'dcimg'
% semiAutoROI will work on dcimg (particular case)

    dcimg = false;
    Z = Layers;
    sp = split(tag, '.');

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % handle dcimg case
    if length(sp) == 1 % if no extension (regular case)
        m = Focused.Mmap(F, tag); % get the memory map
        x = m.x;
        y = m.y;
    else
        if strcmp(sp{end}, 'dcimg') % if extension is dcimg
            dcimg = true;
        else
            error('case not implemented for tag %s', tag);
        end
    end
    if dcimg % if dcimg is true, do it on dcimg
        m = Focused.MmapOnDCIMG(F, sp{1}, {});
        if m.invert.iZ
            Z = flip(Z);
        end        
        if m.invert.iXY
            x = m.y;
            y = m.x;
        else
            x = m.x;
            y = m.y;
        end        
    end

% % % % % % % % % % % % % % % % % % % % % % % % load existing or initialize
    try % try to load existing mask.mat
        disp('found mask file, loading it')
        load(F.tag('mask'), 'mask'); % get the mask
    catch % if no mask variable to load, initialize to NaN
        disp('creating ''Mask'' directory')
        mkdir(F.dir('Mask'));
        disp('creating new mask file')
        mask = false(x,y,20); % default total number of layers
    end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % print at screen
    for z = Z % for each layer of concern
        img = m(:,:,z,t); % load image
        tmp2 = mask(:,:,z); % load mask layer

        % show layer
        hold off; imshow(img, [400 1500]);

        if ~max(max( tmp2 )) % if mask layer is null
            % autocompute mask (TODO add slider)

            % Auto brain countour (Geoffrey)
            bg_img = mean2(img);
            H = fspecial('disk',20);
            tmp1 = imfilter(img,H,'replicate');
            tmp2 = img*0;
            tmp2(tmp1>bg_img*(1-(0.005*z))) = 1;
            tmp2 = bwareaopen(tmp2,(size(img,1)*size(img,2))/4);  

    %         sliderize(z, img, tmp2); % TODO make this work
        end

        % plot contour over this
        hold on; contour(tmp2);

        % get new contour
        tmp2 = editContour(tmp2);
        if strcmp(tmp2, 'exit') % if exit
            fprintf('layer %d was not saved\n', z);
            return
        end

        % stores it in 'mask' variable and saves it
        mask(:,:,z) = tmp2;
        save(F.tag('mask'), 'mask'); % overwrites the mask
        fprintf('saved layer %d\n', z);

    end

    % pause and close current figure
    pause(1); close gcf;

end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % functions

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
    if isempty(boundary_2)
       fprintf('EXIT\n');
       newContour = 'exit';
       return
    end
    BW = poly2mask(boundary_2(:,1), boundary_2(:,2), size(tmp2,1), size(tmp2,2));

    contour(BW)

    newContour = BW;

end

%%% TODO make this function work
%{
function sliderize(z, img, tmp2)
    % show layer
    f = gcf;
    f.Visible = 'off';
    
    % adds slider
    uicontrol('Style', 'slider',...
        'Min',0,'Max',1,...
        'SliderStep', [1/100 1/100], 'Value',1-(0.005*z),...
        'Position', [20 20 300 20],...
        'Callback', @recomputesFilter);
    
    % show image
    f.Visible = 'on'; 
    hold on; contour(tmp2);
    
    % TODO find a way to stop execution since the value is not ok
    
    function recomputesFilter(source, ~)
        bg_img = mean2(img);
        H = fspecial('disk',20);
        tmp1 = imfilter(img,H,'replicate');
        tmp2 = img*0;
        tmp2(tmp1>bg_img*(source.Value)) = 1;
        tmp2 = bwareaopen(tmp2,(size(img,1)*size(img,2))/4);
  
    end

end
%}
