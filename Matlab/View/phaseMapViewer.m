function phaseMapViewer(mAmplitude, mPhase, titleFig, maximum)

% ----- draft phasemap viewer -----

    m = mAmplitude; % neutral alias for position
    
    z = min(mAmplitude.Z);
    
    f = figure('Visible','off'); % create invisible figure
    img = ones(m.x, m.y, 3);	% saturation init to 1
    img(:,:,1) = mod(mPhase(:,:,z,1),2*pi)./(2*pi); 		% hue
    img(:,:,3) = mAmplitude(:,:,z,1)./maximum; 	% value
    img = hsv2rgb(img);
 %   img = rot90(img); % rotate image to display head up
    h = imshow(img);
    title([titleFig '   ' 'z=' num2str(z)]);
    % set(gca,'Ydir','normal') (reverse)

    % ----- SLIDERS -----
    % z slider
    uicontrol('Style', 'slider',...
        'Min',min(m.Z),'Max',max(m.Z),...
        'SliderStep', [1/(max(m.Z)-min(m.Z)) 1/(max(m.Z)-min(m.Z))], 'Value',z,...
        'Position', [20 20 300 20],...
        'Callback', @actualize_z);

    % ----- ----- -----
    
        f.Visible = 'on';
        set(f, 'Position',[20 -20 600 1080]);        
    
    % ----- FUNCTIONS -----
    function actualize_z(source, ~)
        z = floor(source.Value); % round the value
        img = ones(mAmplitude.x, mAmplitude.y, 3);	% saturation init to 1
        img(:,:,1) = mod(mPhase(:,:,z,1),2*pi)./(2*pi); 		% hue
        img(:,:,3) = mAmplitude(:,:,z,1)./maximum; 	% value
        img = hsv2rgb(img);
     %   img = rot90(img); % rotate image to display head up
        set(h, 'Cdata', img); % replaces the image
        title([titleFig '   ' 'z=' num2str(z)]); % replaces the title
        drawnow; % actualizes the figure
    end

    % ----- ----- -----
end
