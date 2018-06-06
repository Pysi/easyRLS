function computeBackground(F)
%computeBackground computes the background using Raphael's function
% tag might be 'corrected'
% RefIndex is the reference index used for drift correction

    RefIndex = F.Analysis.RefIndex;

    % loads mmap
    m = Focused.Mmap(F, 'corrected');

    background = single(NaN(1, 20));

    for z = m.Z
        Img = NT.Image(double(m(:,:,z,RefIndex)));
        background(z) = single(Img.background);
    end

    mkdir(F.dir('Background'));
    save(F.tag('background'), 'background');

end