function tifToRAS(F, Layers, inMode)
%tifToRAS(F, Layers) takes the tif images and write it in a 4D RAS mmap file
% F is the focus on the run
% Layers are the layers concerned
% TODO optimize

    % TODO add the focused way to find RASification
%     inMode = 'RAS'; 
    outMode = 'RAS';
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
    mkdir(F.dir('rawRAS'));
    output = [F.tag('rawRAS') '.bin'];
    outputInfo = [F.tag('rawRAS') '.mat'];

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
                                        % see benchmark at the end
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
    writeNHDR(F, 'rawRAS');
    save(outputInfo, 'x', 'y', 'z', 't', 'Z', 'T', 'space');

end




% when replacing the lign
% tmp = imread(imgName)';
% by
% tic; tmp = imread(imgName)'; toc; 
% you get what follows

% notice the change in image read time
% ~ 0.005 seconds at the beginning
% ~ 0.05 seconds at the end
% with peaks at 0.1 seconds

% the whole thing should be 150 seconds (~ 2 min) long (30000 images)
% it can reach 1500 seconds (~ 20 minutes)
% a ×10 ratio in time is not acceptable

%     Elapsed time is 0.005093 seconds.
%     Elapsed time is 0.005112 seconds.
%     Elapsed time is 0.004711 seconds.
%     Elapsed time is 0.004773 seconds.
%     Elapsed time is 0.005937 seconds.
%     Elapsed time is 0.004876 seconds.
%     Elapsed time is 0.004455 seconds.
%     Elapsed time is 0.004573 seconds.
%     Elapsed time is 0.004626 seconds.
%     Elapsed time is 0.004482 seconds.
%     Elapsed time is 0.004587 seconds.
%     Elapsed time is 0.004617 seconds.
%     Elapsed time is 0.004736 seconds.
%     Elapsed time is 0.004556 seconds.
%     Elapsed time is 0.004741 seconds.
%     Elapsed time is 0.004466 seconds.
%     Elapsed time is 0.004605 seconds.
%     Elapsed time is 0.004518 seconds.
%     Elapsed time is 0.004440 seconds.
%     Elapsed time is 0.004588 seconds.
%     Elapsed time is 0.004898 seconds.
%     Elapsed time is 0.004485 seconds.
%     Elapsed time is 0.004698 seconds.
%     Elapsed time is 0.004951 seconds.
%     Elapsed time is 0.004629 seconds.
%     Elapsed time is 0.004778 seconds.
%     Elapsed time is 0.004517 seconds.
%     Elapsed time is 0.004553 seconds.
%     Elapsed time is 0.005044 seconds.
%     Elapsed time is 0.004519 seconds.
%     Elapsed time is 0.004978 seconds.
%     Elapsed time is 0.004457 seconds.
%     Elapsed time is 0.004589 seconds.
%     Elapsed time is 0.004672 seconds.
%     Elapsed time is 0.004569 seconds.
%     Elapsed time is 0.004957 seconds.
%     Elapsed time is 0.004478 seconds.
%     Elapsed time is 0.066416 seconds.
%     Elapsed time is 0.047433 seconds.
%     Elapsed time is 0.094878 seconds.
%     Elapsed time is 0.090696 seconds.
%     Elapsed time is 0.045818 seconds.
%     Elapsed time is 0.054236 seconds.
%     Elapsed time is 0.091449 seconds.
%     Elapsed time is 0.108056 seconds.
%     Elapsed time is 0.111529 seconds.
%     Elapsed time is 0.059577 seconds.
%     Elapsed time is 0.045892 seconds.
%     Elapsed time is 0.036105 seconds.
%     Elapsed time is 0.081161 seconds.
%     Elapsed time is 0.057147 seconds.
%     Elapsed time is 0.047697 seconds.
%     Elapsed time is 0.048657 seconds.
%     Elapsed time is 0.070031 seconds.
%     Elapsed time is 0.049062 seconds.
%     Elapsed time is 0.041231 seconds.
%     Elapsed time is 0.049745 seconds.
%     Elapsed time is 0.036997 seconds.
%     Elapsed time is 0.056032 seconds.
%     Elapsed time is 0.047780 seconds.
%     Elapsed time is 0.079904 seconds.
%     Elapsed time is 0.034661 seconds.
%     Elapsed time is 0.048777 seconds.
%     Elapsed time is 0.053050 seconds.
%     Elapsed time is 0.048687 seconds.
%     Elapsed time is 0.064410 seconds.
%     Elapsed time is 0.050508 seconds.
%     Elapsed time is 0.048255 seconds.
%     Elapsed time is 0.054540 seconds.
%     Elapsed time is 0.046581 seconds.
%     Elapsed time is 0.068520 seconds.
%     Elapsed time is 0.087677 seconds.
%     Elapsed time is 0.040444 seconds.
%     Elapsed time is 0.083232 seconds.
%     Elapsed time is 0.056471 seconds.
%     Elapsed time is 0.094212 seconds.
%     Elapsed time is 0.049621 seconds.
%     Elapsed time is 0.038649 seconds.
%     Elapsed time is 0.050706 seconds.
%     Elapsed time is 0.034842 seconds.
%     Elapsed time is 0.056106 seconds.
%     Elapsed time is 0.043980 seconds.
%     Elapsed time is 0.045898 seconds.
%     Elapsed time is 0.051191 seconds.
%     Elapsed time is 0.080941 seconds.
%     Elapsed time is 0.062291 seconds.
%     Elapsed time is 0.045428 seconds.
%     Elapsed time is 0.053817 seconds.
%     Elapsed time is 0.045340 seconds.
%     Elapsed time is 0.066237 seconds.
%     Elapsed time is 0.040626 seconds.
%     Elapsed time is 0.053287 seconds.
%     Elapsed time is 0.055525 seconds.
%     Elapsed time is 0.089715 seconds.
%     Elapsed time is 0.063231 seconds.
%     Elapsed time is 0.039717 seconds.
%     Elapsed time is 0.075903 seconds.
%     Elapsed time is 0.033172 seconds.
%     Elapsed time is 0.067902 seconds.
%     Elapsed time is 0.033392 seconds.
%     Elapsed time is 0.098641 seconds.
%     Elapsed time is 0.047424 seconds.
%     Elapsed time is 0.035531 seconds.
%     Elapsed time is 0.055362 seconds.
%     Elapsed time is 0.050644 seconds.
%     Elapsed time is 0.043507 seconds.
%     Elapsed time is 0.043516 seconds.
%     Elapsed time is 0.037587 seconds.
%     Elapsed time is 0.045240 seconds.
%     Elapsed time is 0.034560 seconds.
%     Elapsed time is 0.051429 seconds.
%     Elapsed time is 0.037414 seconds.
%     Elapsed time is 0.082890 seconds.
%     Elapsed time is 0.036501 seconds.
%     Elapsed time is 0.104952 seconds.
%     Elapsed time is 0.049251 seconds.
%     Elapsed time is 0.048129 seconds.
%     Elapsed time is 0.043046 seconds.
%     Elapsed time is 0.068074 seconds.
%     Elapsed time is 0.054510 seconds.
%     Elapsed time is 0.061387 seconds.
%     Elapsed time is 0.053510 seconds.
%     Elapsed time is 0.041726 seconds.
%     Elapsed time is 0.047882 seconds.
%     Elapsed time is 0.062867 seconds.
%     Elapsed time is 0.043555 seconds.
%     Elapsed time is 0.056492 seconds.
%     Elapsed time is 0.030022 seconds.
%     Elapsed time is 0.030083 seconds.
%     Elapsed time is 0.039889 seconds.
%     Elapsed time is 0.049209 seconds.
%     Elapsed time is 0.053672 seconds.
%     Elapsed time is 0.076271 seconds.
%     Elapsed time is 0.098808 seconds.
%     Elapsed time is 0.050199 seconds.
%     Elapsed time is 0.048978 seconds.
%     Elapsed time is 0.043505 seconds.