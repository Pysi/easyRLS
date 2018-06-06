function seeDriftCorrection(F)
%seeDriftCorrection computes and display translated images in real time

    driftPath = fullfile(F.dir('Drift'), 'Drifts.mat');
    load(driftPath, 'dx', 'dy')
    
    m = adapted4DMatrix(F, 'source');
    
    figure
    h = imshow(m(:,:,5,1), [400 800]);
    inc = 2;
    for t = 1:inc:m.t
        img = imtranslate(m(:,:,5,t), [-dy(t), -dx(t)]);
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
