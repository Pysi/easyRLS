function seeDriftCorrection(F, z)
%seeDriftCorrection computes and display translated images in real time

% Z
if ~exist('z', 'var')
    z = 3;
end
uselayer = z;

    driftPath = fullfile(F.dir('Drift'), 'Drifts.mat');
    load(driftPath, 'dx', 'dy')
    
    m = adapted4DMatrix(F, 'source');
    
    figure
    h = imshow(m(:,:,z,1), [400 800]);
    inc = 1;
    for t = 1:inc:m.t
        img = imtranslate(m(:,:,z,t), [-dy(uselayer, t), -dx(uselayer, t)]);
        try
            set(h, 'Cdata', img);
            title(num2str(t))
            drawnow
        catch
            disp('is it ok ?');
            return
        end
    end
    
    clear gcf
end
