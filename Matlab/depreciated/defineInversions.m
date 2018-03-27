function [invertXY, invertX, invertY, invertZ] = defineInversions(inMode, outMode)
%defineInversions defines which transformations to perform

% EX
%     inMode = 'yxzrai'; 
%     outMode = 'xyzras';

    % default values
    invertXY = false;
    invertX = false;
    invertY = false;
    invertZ = false;
    
    % finds right values
    if strcmp(inMode(1:2), 'yx') && strcmp(outMode(1:2), 'xy')
        invertXY = true;
        fprintf('x-y transposition\n');
    end

    if inMode(4) ~= outMode(4)
        invertX = true;
        fprintf('x inversion\n');
    end
    if inMode(5) ~= outMode(5)
        invertY = true;
        fprintf('y inversion\n');
    end
    if inMode(6) ~= outMode(6)
        invertZ = true;
        fprintf('z inversion\n');
    end
    
end