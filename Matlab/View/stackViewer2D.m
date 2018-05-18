function stackViewer2D(F, tag, Layers)
%stackViewer2D(F, tag, Layers) aims to produce the same result as 
%                              stackViewer, but for 2D mmaps
% F is the focus object
% tag is 'baseline' or 'dff'
% Layers are the layers to view

% THIS IS NOT MEANT TO BE UNDERSTANDABLE

minmax = [400 1200];
viewDFF = false;
viewNeuron = false;
if strcmp(tag, 'DFF') || strcmp(tag, 'DFFNeuron')
    viewDFF = true;
end
if strcmp(tag, 'BaselineNeuron') || strcmp(tag, 'DFFNeuron')
    viewNeuron = true;
end

m = cell(1,20); % cell array for matfiles
% Data = cell(1,20); % easyer access to data

try % tries to get a background
    mgray = Focused.Mmap(F, 'graystack');
catch
    try
        mgray = Focused.Mmap(F, 'refStack');
        minmax = [400 4000];
    catch
        error('no gray or ref stack')
    end
end

    for z = Layers
        inputInfo = fullfile(F.dir(tag), [num2str(z, '%02d') '.mat']);
        m{z}.matfile = matfile(inputInfo); % readable matfile (prevents from loading all indices at the same time)
%         Data{z} = m{z}.mmap.Data; % loads reference on bit
    end

    z = Layers(1);
    T = m{z}.matfile.T; % take time (they should be the same for all)
    t = T(1);
    
    mmap = recreateMmap(F,m{z}.matfile.mmap); % recreates mmap, will be actualized when z changes
    if ~viewNeuron
        indices = m{z}.matfile.indices; % loads indices, will be actualized when z changes
    else % (if viewNeuron is true)
        nn = m{z}.matfile.numNeurons; % takes numNeurons
        ns = m{z}.matfile.neuronShape; % takes neuronShape
        snap = mmap.Data.bit(t, :); % takes a snapshot for all neurons at given t
    end

    % ----- 
    f = figure('Visible','off'); 
    % set base image
    if viewDFF; img = NaN(mgray.x, mgray.y);
    else; img = mgray(:,:,z,1);
    end
    
    % fill image
    if ~viewNeuron
        img(indices) = mmap.Data.bit(t,:);
    else % display neuron by neuron
        for i = 1:nn
            img(ns{i}) = snap(i);
        end
    end

    % show image
    if viewDFF; h = imshow(rot90(img), [-.5 2]);
    else; h = imshow(rot90(img), minmax);
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
        clear('indices', 'nn', 'ns');
        clear('mmap');
        mmap = recreateMmap(F,m{z}.matfile.mmap); % actualises mmap
        if ~viewNeuron
            indices = m{z}.matfile.indices;% actualises indices
        else
            nn = m{z}.matfile.numNeurons; % takes numNeurons
            ns = m{z}.matfile.neuronShape; % takes neuronShape
            snap = mmap.Data.bit(t, :); % takes a snapshot for all neurons at given t
        end
        drawImage();
    end

    function actualize_t(source, ~)
        t = floor(source.Value);
        if viewNeuron
            snap = mmap.Data.bit(t, :); % takes a snapshot for all neurons at given t
        end
        drawImage();
    end

    function drawImage()       
        % set base image
        if viewDFF; img = NaN(mgray.x, mgray.y);
        else; img = mgray(:,:,z,1);
        end
        if ~viewNeuron
            img(indices) = mmap.Data.bit(t,:);
        else % display neuron by neuron
            for i = 1:nn
                img(ns{i}) = snap(i);
            end
        end
        set(h, 'Cdata', rot90(img));
        title([F.name '   z=' num2str(z) '   t=' num2str(t)]);
        drawnow;
    end
    
end
