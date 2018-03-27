function imgOut = transposeImage(imgIn, invertXY, invertX, invertY)
%transposeImage transposes image if invertXY is on, flips X if invertX is on...
imgOut = imgIn;

% transpose image
    if invertXY
        imgOut = imgOut';
    end
    if invertX
        imgOut = flip(imgOut, 1);
    end
    if invertY
        imgOut = flip(imgOut, 2);
    end
    
end