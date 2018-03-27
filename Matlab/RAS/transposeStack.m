function stackOut = transposeStack(stackIn, invertXY, invertX, invertY, invertZ)
%transposeStack(stackIn, invertXY, invertX, invertY, invertZ)
%    is like transposeImage, but more for dimension 4
% TODO write it properly
stackOut = stackIn;

% transpose 
    if invertXY
        stackOut = permute(stackOut, [2 1 3 4]);
    end
    if invertX
        stackOut = flip(stackOut, 1);
    end
    if invertY
        stackOut = flip(stackOut, 2);
    end
    if invertZ
        stackOut = flip(stackOut, 3);
    end
    
end