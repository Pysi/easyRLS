function dffPixel(F, Layers)
%dffPixel computes delta f over f
% F focus object
% Layers layers you want to compute dff on (ex [3 4 6])

% create dff directory
dffPath = fullfile(F.dir.IP, 'dff_pixel');
disp('creating ''dff_pixel'' directory'); mkdir(dffPath);

% load background and convert to uint16
load(fullfile(F.dir.IP, 'background.mat'), 'background');

    for z = Layers
        
        % sigstack (x,y,z,t) ((xy,z,t))
        msig = Focused.Mmap(F, 'corrected');
        m = msig; % just an alias for getting values
        % basestack (t, xy)
        basePath = fullfile(F.dir.IP, 'baseline_pixel', [num2str(z, '%02d') '.mat']);
        load(basePath, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'indices', 'numIndex');
        mbas = recreateMmap(F,mmap);
                
        output = fullfile(dffPath, [num2str(z, '%02d') '.bin']);
        outputInfo = fullfile(dffPath, [num2str(z, '%02d') '.mat']);
        
        fid = fopen(output, 'wb');
        
        tic
        % compute dff
        % (signal - baseline) / (baseline - background)
        % single( uint16 - uint16 ) / (single(uint16) - single)
        fwrite(fid,...
            single( squeeze(msig(indices, z, :))' - mbas.Data.bit(:,:) ) ./ ...
                ( single(mbas.Data.bit(:,:)) - background(z) ),...
            'single');
        
        fprintf('computing dff per pixel for layer %d: %.02f s\n', z, toc)

        fclose(fid);
        
        % get values
        x = m.x; %#ok<*NASGU>
        y = m.y;
        % z
        t = m.t;
        Z = z; 
        T = m.T;

        % create corresponding mmap info
        mmap = memmapfile(output,...
            'Format',{'single', [t, numIndex],'bit'});
        save(outputInfo, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'indices', 'numIndex');

    end
end
