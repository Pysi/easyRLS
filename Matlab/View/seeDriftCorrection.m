function seeDriftCorrection(F, tag)
%seeDriftCorrection computes and display translated images in real time

    driftPath = fullfile(F.dir('Drift'), 'Drifts.mat');
    load(driftPath, 'dx', 'dy')
    
    m = adapted4DMatrix(F, tag);
    
    figure
    h = imshow(m(:,:,5,1), [400 800]);
    for t = 1:10:m.t
        img = imtranslate(m(:,:,5,t), [-dy(t), -dx(t)]);
        set(h, 'Cdata', img);
        title(num2str(t))
        drawnow
        
    end
    
    clear gcf
end
