function tifToRAS(F, Layers)
%tifToRAS(F, Layers) takes the tif images and write it in a 4D RAS mmap file
% F is the focus on the run
% Layers are the layers concerned
% TODO optimize

    % TODO add the focused way to find RASification
    inMode = 'ali'; 
    outMode = 'ras';
    [invertXY, invertX, invertY, invertZ] = defInvert(inMode, outMode);

    % defines X and Y    
    %     in 'update_info'
    %     this.width = size(this.pix, 2);
    %     this.height = size(this.pix, 1);
    if invertXY
        X = 1:F.IP.width;           % x size
        Y = 1:F.IP.height;          % y size
    else
        Y = 1:F.IP.width;           % x size
        X = 1:F.IP.height;          % y size
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
    BUFFER = NaN(length(Y), length(X), length(Z));
    
        for z = Z % along z
            F.select(F.sets(z).id);
            imgName = F.imageName(t); % 'rel' if necessary
            tmp = imread(imgName);     % reads image (sometimes very long ??)
            pix = transposeImage(tmp, ~invertXY, invertX, invertY); % ~
            BUFFER(:,:,z) = pix;
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

    % save info to a matlab file
    save(outputInfo, 'x', 'y', 'z', 't', 'Z', 'T');

end