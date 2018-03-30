function dcimgRASdrift(F, tag, kwargs)
%dcimgRASdrift takes dcimg stack, corrects orientation, computes drift, and records corrected stack
% it is a shortcut function to perform several tasks, so it contains redundant code

% cette fonction est longue car elle combine plusieurs fonctions en une seule

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%  Attention : comme pour driftCompute                      %
%  - utilisation du max des layers selectionnés             %
%  - bbox définie dans le programme                         %
%  - enregistrement des drifts dans des dossiers séparés    %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

    % TODO find kwargs (x,y,z,t) in focus
    m = Focused.MmapOnDCIMG(F, tag, {});

% ------------------ RAS parameters -----------------------
    % TODO add the focused way to find RASification
    inMode = 'ali'; 
    outMode = 'ras';
    f = getTransformation(inMode, outMode);
    
% -------------------- drift parameters --------------------
    % parse input to change reference stack TODO write validation function
    in = inputParser;
    in.addParameter('RefIndex', 10);        % by default 10th stack
    in.addParameter('RefLayers', 8:10);     % by default stacks 8, 9, 10
    in.addParameter('Layers', 3:12); % default
    in.parse(kwargs{:})

    % Layers = in.Results.Layers;
    RefIndex = in.Results.RefIndex;
    RefLayers = in.Results.RefLayers;
    
    Z = in.Results.Layers;
    % corrects Z if necessary
    if invertZ
        Z = flip(Z);
    end

    % --- Define reference image ---
    % the reference image we take is the maximum of the selected layers along
    % the 3rd dimension

    bbox = [ 53 566 45 914 ]; % define bounding box to look into
    % adapt bounding box
    if invertXY
        Y = bbox(1):bbox(2);
        X = bbox(3):bbox(4);
    else
        X = bbox(1):bbox(2);
        Y = bbox(3):bbox(4);
    end
    
    % compute reference image with max
    Ref = max(m(X,Y, RefLayers, RefIndex),[],3);
    Ref = applyTransformation(Ref, f);
    
    NTRef = NT.Image(Ref); % @image version of ref image
    
    % creates a figure to plot the drift correction
    figure; hold on;
    title([F.name '   dx=red, dy=blue']);

    % init drift vectors
    dx = zeros(1,m.t);
    dy = zeros(1,m.t);
    
% ------------------- loop ---------------------------
	% open in write binary mode
    outputPathTag = fullfile(F.dir.files, 'corrected');
	fid = fopen([outputPathTag '.bin'], 'wb');
    w = waitbar(0, 'performing drift correction on dcimg');
    T = m.T;
    
	% loop over images
    for t = T % along time
        waitbar(t/m.t)
        
        % compute the image to compare with the ref image
        Img = max( m(X,Y,RefLayers,t) ,[],3);
        Img = applyTransformation(Img, f);
        
        NTImg = NT.Image( Img ); % @image version of image

        % compute the DX and DY with the Fourier transform
        [dx(t), dy(t)] = NTRef.fcorr(NTImg);

        % plot 1/50 figures
        if ~mod(t,50)
            plot(t-49:t,dy(t-49:t),'b.');
            plot(t-49:t,dx(t-49:t),'r.');
            pause(0.01);
        end   

        for z = Z % along z
            % writes corrected image (for all Z)
            
            % get image
            Img = m(:,:,z,t);
            Img = applyTransformation(Img, f);
            
            % translate image
            Img = imtranslate(Img, [-dy(t), -dx(t)]);
            
            % write image
            fwrite(fid, Img, 'uint16');
        end
    end	
	
	close(w)
	fclose(fid);
    close gcf
    
    % --- Save drift parameters ---
    % save bbox and drifts
    disp('making ''IP'' directory');
    mkdir(F.dir.IP);
    save(fullfile(F.dir.IP, 'DriftBox'), 'bbox');
    save(fullfile(F.dir.IP, 'Drifts'), 'dx', 'dy');
    savefig(fullfile(F.dir.IP, 'driftCorrection'));

    % defines x and y
    if invertXY
        x = m.y;
        y = m.x;
    else
        x = m.x;
        y = m.y;
    end
    z = length(Z); %#ok<*NASGU>
    t = m.t; % (could be useless)
    % Z defined by layers (might be flipped)
    % T defined before loop
    
    save([outputPathTag '.mat'], 'x', 'y', 'z', 't', 'Z', 'T');

end