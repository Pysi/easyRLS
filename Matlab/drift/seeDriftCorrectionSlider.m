function seeDriftCorrectionSlider(F, z)
%seeDriftCorrection computes and display translated images in real time

Ax = 0.3;
Ay = 1.8;
Aphi = 1.1;
sinusStim = @(A,t,phi) A * sin( 119.92 * 2*pi * (t-1)/F.param.NCycles -3*pi/4 * phi);

% Z
if ~exist('z', 'var')
    z = 3;
end
uselayer = z;

    driftPath = fullfile(F.dir('Drift'), 'Drifts.mat');
    load(driftPath, 'dx', 'dy')
    
    m = adapted4DMatrix(F, 'source');
    
    figure
    h = imshow(m(:,:,z,1), [400 450]);
    
    uicontrol('Style', 'slider',...
        'Min',1.6,'Max',2,...
        'SliderStep', [1/500 1/500], 'Value',Ay,...
        'Position', [20 40 900 20],...
        'Callback', @actualize_Ay);
    
    uicontrol('Style', 'slider',...
        'Min',0.2,'Max',0.5,...
        'SliderStep', [1/500 1/500], 'Value',Ax,...
        'Position', [20 60 900 20],...
        'Callback', @actualize_Ax);
    
    uicontrol('Style', 'slider',...
        'Min',0.95,'Max',1.2,...
        'SliderStep', [1/1000 1/1000], 'Value',Aphi,...
        'Position', [20 20 900 20],...
        'Callback', @actualize_Phi);
    
    
    inc = 1;
    t = 1;
    while true
        t = t+inc;
        if t > F.param.NCycles
            t=1;
        end
        img = imtranslate(m(:,:,z,t), [-sinusStim(Ay, t, Aphi), -sinusStim(Ax, t, Aphi)]);
        try
            set(h, 'Cdata', img);
            title([num2str(t) ' Ax=' num2str(Ax) ' Ay=' num2str(Ay) ' Aphi=' num2str(Aphi)])
            drawnow
        catch
            fprintf('returned: Ay=%.03f, Ax=%.03f, Aphi=%.03f\n', Ay, Ax, Aphi);
            return
        end
    end
    
    clear gcf
    
    
    function actualize_Ay(source, ~)
        Ay = source.Value;
    end
    function actualize_Ax(source, ~)
        Ax = source.Value;
    end
    function actualize_Phi(source, ~)
        Aphi = source.Value;
    end
    
end
