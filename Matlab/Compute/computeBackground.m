function computeBackground(F)
%computeBackground computes the background using Raphael's function
% tag might be 'corrected'
% RefIndex is the reference index used for drift correction

F.Analysis.Background.MaxValue = 500; % upper limit for background
F.Analysis.Background.Decrease = 10; % decrease the found background by this value to avoid being higher than baseline

    % create folder
    Focused.mkdir(F, 'Background');

    RefIndex = F.Analysis.RefIndex;

    % loads mmap
    m = Focused.Mmap(F, 'corrected');

    background = single(NaN(1, 20));

    for z = m.Z
        Img = NT.Image(double(m(:,:,z,RefIndex)));
        background(z) = single(Img.background);
    end
    
    % /!\ background verification
    THRESHOLD = F.Analysis.Background.MaxValue;
    if max(background) > THRESHOLD % very unlikely value for background
        miniBackground = min(background);
        warning('unlikely high value for background :\n%s\nsetting values above %d to min (%f)\n', num2str(background), THRESHOLD, miniBackground);
        for z = m.Z
            if background(z) > THRESHOLD
                background(z) = miniBackground;
            end
        end
    end

    % decrease background
    background = background - F.Analysis.Background.Decrease;
    save(F.tag('background'), 'background');

end