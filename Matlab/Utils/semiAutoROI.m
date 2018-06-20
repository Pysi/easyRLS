function semiAutoROI(F)
%semiAutoROI(F, Layers, t, tag) lets you modify an automatic ROI
% F is the current focus instance
% tag could be :
%     - the tag of the binary you want to work on ('corrected' for instance)
%     - the name of a dcimg if you want to work on a dcimg (Run00.dcimg for instance)

    % set local parameters
    minmax = [400 1200]; % minmax values for display
    discretize = 50; % lower values means more point on contour
    
    % get global parameters
    Z = F.Analysis.Layers;
    t = F.Analysis.RefIndex;
    
% if the tag has an extension and that this extension is 'dcimg'
% semiAutoROI will work on dcimg (particular case)

    m = adapted4DMatrix(F,'source');

% % % % % % % % % % % % % % % % % % % % % % % % load existing or initialize
    try % try to load existing mask.mat
        disp('found mask file, loading it')
        load(F.tag('mask'), 'mask'); % get the mask
    catch % if no mask variable to load, initialize to NaN
        Focused.mkdir(F, 'Mask');
        disp('creating new mask file')
        mask = false(m.x,m.y,20); % default total number of layers
    end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % print at screen
    for z = Z % for each layer of concern
        img = m(:,:,z,t); % load image
        tmp2 = mask(:,:,z); % load mask layer

        % show layer
        hold off; f = imshow(img, minmax);

        if ~max(max( tmp2 )) % if mask layer is null
            % autocompute mask (TODO add slider)

            % Auto brain countour (Geoffrey)
<<<<<<< HEAD
            bg_img = mean2(img);
            H = fspecial('disk',20);
            tmp1 = imfilter(img,H,'replicate');
            tmp2 = img*0;
            tmp2(tmp1>bg_img*(1-(0.005*z))) = 1;
            tmp2 = bwareaopen(tmp2,(size(img,1)*size(img,2))/4);
            count = 4;
            while mean2(tmp2) == 0
                count = count+1;
                tmp2(tmp1>bg_img*(1-(0.005*z))) = 1;
                tmp2 = bwareaopen(tmp2,round((size(img,1)*size(img,2))/count));
            end
=======
            if F.Analysis.Lineage == 'cytoplasmic'
                bg_img = mean2(img);
                H = fspecial('disk',20);
                tmp1 = imfilter(img,H,'replicate');
                tmp2 = img*0;
                tmp2(tmp1>bg_img*(1-(0.005*z))) = 1;
                tmp2 = bwareaopen(tmp2,(size(img,1)*size(img,2))/4);
                count = 4;
                while mean2(tmp2) == 0
                    count = count+1;
                    tmp2(tmp1>bg_img*(1-(0.005*z))) = 1;
                    tmp2 = bwareaopen(tmp2,round((size(img,1)*size(img,2))/count));
                end
            else
                tmp0 = img;
                tmp0(rangefilt(img) < mean2(rangefilt(img)/((Z(end)+1)/(Z(end) - z + 1)))) = 0;
                [B, L] = bwboundaries(tmp0);
                tmp0(L == 0) = 0;
                bg_img = mean2(img);
                H = fspecial('disk',1);
                tmp0 = imfilter(tmp0,H,'replicate');
                tmp2 = bwareaopen(tmp0,(size(img,1)*size(img,2))/4);
            end
                

>>>>>>> Geoffrey
    %         sliderize(z, img, tmp2); % TODO make this work
        end

        % plot contour over this
        hold on; contour(tmp2);

        % get new contour
        tmp2 = editContour(f, tmp2, discretize);
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

function newContour = editContour(f, oldContour, discretize)
% getContour lets manually edit the contour

    tmp2 = oldContour;

    [B, ~] = bwboundaries(tmp2,'noholes');
    boundary = B{1};
    boundary = boundary(1:discretize:end, :); % reduce the number of points by discretize
    for k = 1:length(B)
        plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
    end
    poly = impoly(gca, [boundary(:,2) boundary(:,1)]);


    boundary_2 = poly.wait;
    if ~ishandle(f) % if figure was quit
       fprintf('EXIT\n');
       newContour = 'exit';
       return
    end
    if isempty(boundary_2) % if poly was deleted
        disp('draw your own poly');
        poly = impoly;
        boundary_2 = poly.wait;
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
