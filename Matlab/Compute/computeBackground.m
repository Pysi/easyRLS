function computeBackground(F, tag, RefIndex)
%computeBackground computes the background using Raphael's function
% tag might be 'corrected'
% RefIndex is the reference index used for drift correction

    % loads mmap
    m = Focused.Mmap(F, tag);

    background = single(NaN(1, 20));

    for z = m.Z
        Img = NT.Image(double(m(:,:,z,RefIndex)));
        background(z) = single(Img.background);
    end

    save(fullfile(F.dir.IP, 'background.mat'), 'background');

end