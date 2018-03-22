function stackViewer2D(F, tag, Layers)
%stackViewer2D aims to produce the same result as stackViewer, but for 2D mmaps
% problem : necessity to 'load' indices (even matfile is not good)

warning('This data visualizer is slow due to indexes loading. Changing layer might be 30 s long');

viewDFF = false;
if strcmp(tag, 'dff')
    viewDFF = true;
end

m = cell(1,20); % cell array for all possible layers
mgray = Focused.Mmap(F, 'IP/graystack');

    for z = Layers
        inputInfo = fullfile(F.dir.IP, tag, [num2str(z, '%02d') '.mat']);
        m{z}.matfile = matfile(inputInfo); % readable matfile (prevents from loading all indices at the same time)
        m{z}.mmap = m{z}.matfile.mmap; % TODO reconstruct
    end

    z = Layers(1);
    T = m{z}.matfile.T; % take time (they should be the same for all)
    t = T(1);

    % ----- 
    f = figure('Visible','off'); 
    % set base image
    if viewDFF; img = NaN(mgray.x, mgray.y);
    else; img = mgray(:,:,z,1);
    end
    
    % fill image
    img(m{z}.matfile.indices) = m{z}.mmap.Data.bit(t,:);

    % show image
    if viewDFF; h = imshow(rot90(img), [-.5 2]);
    else; h = imshow(rot90(img), [400 1500]);
    end
    title([F.name '   z=' num2str(z) '   t=' num2str(t)]);
    % -----

    % ----- SLIDERS -----
    % z slider
    uicontrol('Style', 'slider',...
        'Min',Layers(1),'Max',Layers(end),...
        'SliderStep', [1/(max(Layers)-min(Layers)) 1/(max(Layers)-min(Layers))], 'Value',z,...
        'Position', [20 20 300 20],...
        'Callback', @actualize_z);

    if length(T) > 1
        % t slider
        uicontrol('Style', 'slider',...
            'Min', T(1),'Max', T(end),...
            'SliderStep', [10/(T(end)-T(1)) 10/(T(end)-T(1))], 'Value',t,...
            'Position', [20 40 550 20],...
            'Callback', @actualize_t); %#ok<*COLND>
    end
    % ----- ----- -----

        f.Visible = 'on';
        set(f, 'Position',[20 -20 600 1080]);
    
    % ----- FUNCTIONS -----
    function actualize_z(source, ~)
        z = floor(source.Value);
        drawImage();
    end

    function actualize_t(source, ~)
        t = floor(source.Value);
        drawImage();
    end

    function drawImage()       
        % set base image
        if viewDFF; img = NaN(mgray.x, mgray.y);
        else; img = mgray(:,:,z,1);
        end
        fprintf('filling: ');tic;img(m{z}.matfile.indices) = m{z}.mmap.Data.bit(t,:);toc;
        set(h, 'Cdata', rot90(img));
        title([F.name '   z=' num2str(z) '   t=' num2str(t)]);
        drawnow;
    end
    
end
