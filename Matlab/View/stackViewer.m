function stackViewer(m, titleFig, mask)
%stackViewer is analog to imageJ hyperstack
% it allows to visualize the brain and browse z and t directions
% it realises a permutation permute(m,[2,1]) before printing thanks 

    viewMask = false;
    
    if ~isempty(mask) % particular case to view mask contour
        viewMask = true;
        mask = rot90(mask); % permute(mask, [2 1 3]); % permute mask (NO) (transposition)
    end
    
    z = max(m.Z);
    t = m.T(1);
    if viewMask; t = 10; end % TODO : pass reference stack
    
    f = figure('Visible','off'); % create invisible figure
    img = rot90(m(:,:,z,t)); % load transposed image
    h = imshow(img, [400 1500]);
    title([titleFig '   ' 'z=' num2str(z) '   t=' num2str(t)]);
    % set(gca,'Ydir','normal') (reverse)

    % ----- SLIDERS -----
    % z slider
    uicontrol('Style', 'slider',...
        'Min',min(m.Z),'Max',max(m.Z),...
        'SliderStep', [1/(max(m.Z)-min(m.Z)) 1/(max(m.Z)-min(m.Z))], 'Value',z,...
        'Position', [20 20 300 20],...
        'Callback', @actualize_z);

    if m.t > 1 && ~viewMask % no time slider if not necessary
        % t slider
        uicontrol('Style', 'slider',...
            'Min',m.T(1),'Max',m.T(end),...
            'SliderStep', [1/(m.T(end)-m.T(1)) 1/(m.T(end)-m.T(1))], 'Value',t,...
            'Position', [20 40 550 20],...
            'Callback', @actualize_t);
    end
    % ----- ----- -----
    
        f.Visible = 'on';
        set(f, 'Position',[20 -20 600 1080]);
        if viewMask; hold on; [~,cont] = contour(mask(:,:,z),'r'); end
        
    
    % ----- FUNCTIONS -----
    function actualize_z(source, ~)
        z = floor(source.Value); % round the value
        img = rot90(m(:,:,z,t)); % get the transposed image
        set(h, 'Cdata', img); % replaces the image
        if viewMask; delete(cont); [~,cont] = contour(mask(:,:,z),'r'); end % replaces the contour
        title([titleFig '   ' 'z=' num2str(z) '   t=' num2str(t)]); % replaces the title
        drawnow; % actualizes the figure
    end

    function actualize_t(source, ~)
        t = floor(source.Value);
        img = rot90(m(:,:,z,t));
        set(h, 'Cdata', img);
        title([titleFig '   ' 'z=' num2str(z) '   t=' num2str(t)]);
        drawnow;
    end
    % ----- ----- -----
end
