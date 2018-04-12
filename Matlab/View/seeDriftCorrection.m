function seeDriftCorrection(F)
%seeDriftCorrection(F) computes and display translated images in real time

    driftPath = fullfile(F.dir.IP, 'Drifts.mat');
    load(driftPath, 'dx', 'dy')
    
    m = Focused.Mmap(F, 'rawRAS');
    
    figure
    h = imshow(m(:,:,m.Z(1),1), [400 800]);
    for t = 1:10:m.t
        img = imtranslate(m(:,:,m.Z(1),t), [-dx(t), -dy(t)]);
        set(h, 'Cdata', img);
        drawnow
    end
    
    clear gcf
end
