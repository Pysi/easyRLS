function [invertXY, invertX, invertY, invertZ] = defInvert(inMode, outMode)
%defInvert defines which transformations to perform

% EX
%     inMode = 'ali'; 
%     outMode = 'ras';

    % default values
    invertXY = false;
    invertX = false;
    invertY = false;
    invertZ = false;
    
    try % tries to finds right values
        if findpos(inMode, 'x') == findpos(outMode, 'y') && ...
           findpos(inMode, 'y') == findpos(outMode, 'x') 
            invertXY = true;
            fprintf('x-y transposition\n');
        end
        if direction(inMode, 'x') ~= direction(outMode, 'x')
            invertX = true;
            fprintf('x inversion\n');
        end
        if direction(inMode, 'y') ~= direction(outMode, 'y')
            invertY = true;
            fprintf('y inversion\n');
        end
        if direction(inMode, 'z') ~= direction(outMode, 'z')
            invertZ = true;
            fprintf('z inversion\n');
        end
    catch % for example, if a direction is repeted twice, or there is no x axis
        error('there might be some problem with inMode = %s and outMode = %s', inMode, outMode);
    end  
    
end

function pos = findpos(inMode, dim)
%findpos returns the position of the given dimension (x, y, z)

% 1st dim x : L → R
% 2nd dim y : P → A
% 3rd dim z : I → S

    % position function
    findc = @(in, c) find(~(in-c)); % finds a character in the inMode
    findm = @(in, c1, c2) [findc(in, c1) findc(in, c2)]; % finds whether c1 or c2 if exist
    
    inMode = upper(inMode);
    
    if dim == 'x'
        pos = findm(inMode, 'L', 'R'); % finds or character 1 or 2
    elseif dim == 'y'
        pos = findm(inMode, 'P', 'A'); % finds or character 1 or 2
    elseif dim == 'z'
        pos = findm(inMode, 'I', 'S'); % finds or character 1 or 2        
    end
    
end

function val = direction(inMode, dim)
% direction returns the direction of the dim axis
% ex: for x, returns l or r

    val = upper(inMode(findpos(inMode, dim)));
    
end
    
   