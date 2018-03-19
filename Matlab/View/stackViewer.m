function stackViewer(F, tag)
%stackViewer is analog to imageJ hyperstack
% it allows to visualize the brain and browse z and t directions
% it realises a permutation permute(m,[2,1]) before printing thanks 

    m = Focused.Mmap(F, tag);

    f = figure('Visible','off'); 

    z = max(m.Z);
    t = m.T(1);

    img = m(:,:,z,t)';

    h = imshow(img, [400 700]);
    title([F.name '   ' 'z=' num2str(z) '   t=' num2str(t)]);
    set(gca,'Ydir','normal')

    % z slider
    uicontrol('Style', 'slider',...
        'Min',min(m.Z),'Max',max(m.Z),...
        'SliderStep', [1/(max(m.Z)-min(m.Z)) 1/(max(m.Z)-min(m.Z))], 'Value',z,...
        'Position', [20 20 300 20],...
        'Callback', @actualize_z);

    if m.t > 1
        % t slider
        uicontrol('Style', 'slider',...
            'Min',m.T(1),'Max',m.T(end),...
            'SliderStep', [1/(m.T(end)-m.T(1)) 1/(m.T(end)-m.T(1))], 'Value',t,...
            'Position', [20 40 550 20],...
            'Callback', @actualize_t);
    end

        f.Visible = 'on';
        set(f, 'Position',[0 0 600 1080]);
    
    function actualize_z(source, ~)
        z = floor(source.Value);
        img = m(:,:,z,t)';
        set(h, 'Cdata', img);
        title([F.name '   ' 'z=' num2str(z) '   t=' num2str(t)]);
        drawnow;
    end

    function actualize_t(source, ~)
        t = floor(source.Value);
        img = m(:,:,z,t)';
        set(h, 'Cdata', img);
        title([F.name '   ' 'z=' num2str(z) '   t=' num2str(t)]);
        drawnow;
    end
end
