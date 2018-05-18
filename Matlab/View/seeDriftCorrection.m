function seeDriftCorrection(F)
%seeDriftCorrection(F) computes and display translated images in real time

    driftPath = fullfile(F.dir('Drift'), 'Drifts.mat');
    load(driftPath, 'dx', 'dy')
    
    m = Focused.Mmap(F, 'rawRAS');
    
    figure
    h = imshow(m(:,:,m.Z(1),1), [400 800]);
    for t = 1:10:m.t
        img = imtranslate(m(:,:,m.Z(1),t), [-dy(t), -dx(t)]);
        set(h, 'Cdata', img);
        title(num2str(t))
        drawnow
        
    end
    
    clear gcf
end
