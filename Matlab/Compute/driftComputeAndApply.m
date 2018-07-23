function driftComputeAndApply(F,Visible)
%driftApply(F) creates a binary file with the translated values
    
    % setup
    RefStack = F.Analysis.RefStack;
    RefIndex = F.Analysis.RefIndex;
    RefLayers = F.Analysis.RefLayers;

    % create wrapper object
    m = adapted4DMatrix(F,'source');
    mRef = false;
    
    if RefStack % if we want to use a reference stack which is outside the stack
        disp(['########## We want to use a reference stack which is outside the stack => ', RefStack, ' ##########']);
        mRef = Focused.Mmap(F, RefStack);
        RefIndex = false;
    end

    % --- manage case of reference stack
    if mRef~=false % if reference stack wanted
        RefIndex = 1;
    else % take it from m
        mRef=m;
    end
    
    % get layers to analyse and put them in inferior to superior order
    Z = F.Analysis.Layers;
    Z = sort(Z, 'descend');

%     % load drift
%     driftPath = fullfile(F.dir('Drift'), 'Drifts.mat');
%     load(driftPath, 'dx', 'dy')

    % load mmap info
    m = adapted4DMatrix(F, 'source');

    % define output files
    Focused.mkdir(F, 'corrected');
    output = [F.tag('corrected') '.bin'];
    outputInfo = [F.tag('corrected') '.mat'];

    
    % init drift vectors
    dx = zeros(F.param.NLayers,m.t);
    dy = zeros(F.param.NLayers,m.t);

    bbox = F.Analysis.DriftBox; % define bounding box to look into
% --- Select ROI for drift correction ---
%         disp('Please select ROI for drift correction')
%         roi = imrect;
%         wait(roi);
%         pos = getPosition(roi);
%         bbox = [round(pos(1))  round(pos(1) + pos(3)) ...
%             round(pos(2))  round(pos(2) + pos(4))];
%         Ref.region(bbox);

X = bbox(1):bbox(2);
Y = bbox(3):bbox(4);

% --- Drift correction ---
% creates a figure to plot the drift correction
seeDrift = figure('visible',Visible); hold on;
title([F.name '   dx=red, dy=green   for layer',num2str(min(Z))]);

    
switch Visible
    case 'on'
        w = waitbar(0, {'Applying computed drift', ['frame ' num2str(0) '/' num2str(m.t)]});
    case 'off'
end
    for z = Z
        Ref{z} = NT.Image(mRef( X,Y,z, RefIndex ) );
    end
    
    % write the binary file
    fid = fopen(output, 'wb');
    for t = m.T % along t
        for z = Z % along z
            % load reference image and load it in Raphael's image object
            % load the image to compare with the ref image
            Img_raw = NT.Image( m(:,:,z,t) ) ;
            Img =NT.Image(Img_raw.pix(X,Y));
 	        
            % compute the DX and DY with the Fourier transform
            [dx(z,t), dy(z,t)] = Ref{z}.fcorr(Img);

            fwrite(fid,...
                imtranslate(Img_raw.pix,...
                [-dy(z,t), -dx(z,t)]),... %  'x' of a matlab image is 'y'
                'uint16'); % apply dy on rows (y) and dx on columns (x)
        end
        switch Visible
            case 'on'
                waitbar(t/m.t, w, {'Applying computed drift', ['frame ' num2str(t) '/' num2str(m.t)]})
            case 'off'
        end
    
        % plot 1/50 figures
        NN = 50;
        if ~mod(t,NN)
            switch Visible
                case 'on'
                    try
                        figure(seeDrift);
                    catch
                        error('killing the figure stops the computation');
                    end
                case 'off'
                    set(0,'CurrentFigure',seeDrift)
            end
            plot(t-(NN-1):t,dx(min(Z),t-(NN-1):t),'r.');
            plot(t-(NN-1):t,dy(min(Z),t-(NN-1):t),'g.');
            pause(0.01);
            
            z
            t
        end   

    
    end
    fclose(fid);
switch Visible
    case 'on'
         close(w)
    case 'off'
end

    x=m.x; %#ok<*NASGU>
    y=m.y;
%     z=m.z;
    z=length(Z);
    t=m.t;
%     Z=m.Z;
    T=m.T;
    space = m.space;
    pixtype='uint16';
    
    % --- Save ---
     
    % save info to a matlab file
    save(outputInfo, 'x', 'y', 'z', 't', 'Z', 'T', 'space','pixtype');
    writeNHDR(F, 'corrected');
   
    % save bbox and drifts
    Focused.mkdir(F, 'Drift');
    save(fullfile(F.dir('Drift'), 'DriftBox.mat'), 'bbox');
    save(fullfile(F.dir('Drift'), 'Drifts.mat'), 'dx', 'dy');
    savefig(seeDrift,fullfile(F.dir('Drift'), 'driftCorrection.fig'));


end
