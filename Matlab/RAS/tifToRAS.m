function tifToRAS(F, Layers)
%tifToRAS(F, Layers) takes the tif images and write it in a 4D RAS mmap file
% F is the focus on the run
% Layers are the layers concerned
% TODO optimize

    % TODO add the focused way to find RASification
    inMode = 'ali'; 
    outMode = 'ras';
    [f, inversions, order] = getTransformation(inMode, outMode);
    invertZ = inversions(3); % /!\ assuming z is 3rd
    invertXY = ( order(1)==2 ); % /!\ assuming x and y are 1st and 2nd    

    % defines X and Y    
    %     in 'update_info'
    %     this.height = size(this.pix, 1);
    %     this.width = size(this.pix, 2);
    if invertXY
        X = 1:1:F.IP.height;          % x size (first dimension) = rows 'Y'
        Y = 1:1:F.IP.width;           % y size (second dimension) = cols 'X'
    else
        Y = 1:1:F.IP.height;          % x size (first dimension) = rows 'Y'
        X = 1:1:F.IP.width;           % y size (second dimension) = cols 'X'
    end
    %defines Z
    if invertZ
        Z = flip(Layers);
    else
        Z = Layers;
    end
    % defines T
    T = 1:F.param.NCycles;
    
    % define output files
    output = fullfile(F.dir.files, 'rawRAS.bin');
    outputInfo = fullfile(F.dir.files, 'rawRAS.mat');

    w = waitbar(0, 'Converting TIF to RAS bin');

    % write the binary file
    fid = fopen(output, 'wb');
    for t = T % along t
        
    % a buffer avoids switching reading and writing very fast
    % (is it useful ?)
    BUFFER = NaN(length(X), length(Y), length(Z));
    izb = 1; % z iterator over buffer
    
        for z = Z % along z
            F.select(F.sets(z).id);
            imgName = F.imageName(t); % 'rel' if necessary
            
            % % % when doing imread, the number of columns 'X', is the second
            % % % dimension of the matrix and corresponds to the 'x' in imageJ
            tmp = imread(imgName)';     % reads image (sometimes very long ??)
                                        % then transpose to make 1rst
                                        % dimension being x
            pix = applyTransformation(tmp, f); % ~
            BUFFER(:,:,izb) = pix;
            izb = izb +1 ; % writes on the next slice of the buffer
        end
        fwrite(fid, BUFFER, 'uint16'); % fwrite writes along the columns
        waitbar(t/T(end), w, sprintf('Converting TIF to RAS bin\n%d/%d frames done', t, T(end)))
    end
    fclose(fid);

    close(w)

    % get the dimensions of the 4D matrix
    x = length(X); % first dimension
    y = length(Y); % second dimension
    z = length(Z); % number of layers of interest
    t = length(T); % number of frames par layer
    space = 'RAST';

    % save info to a matlab file
    save(outputInfo, 'x', 'y', 'z', 't', 'Z', 'T', 'space');

end