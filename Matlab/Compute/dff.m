function dff(F, Layers)
%dff computes dff for current brain

% create dff directory
dffPath = fullfile(F.dir.IP, 'dff');
disp('creating ''dff'' directory'); mkdir(dffPath);

% load background and convert to uint16
load(fullfile(F.dir.IP, 'background.mat'), 'background');
background = uint16(background); %#ok<NODEF>

    for z = Layers
        
        % sigstack (x,y,z,t) ((xy,z,t))
        msig = Focused.Mmap(F, 'corrected');
        m = msig;
        % basestack (t, xy)
        basePath = fullfile(F.dir.IP, 'baseline', [num2str(z, '%02d') '.mat']);
        load(basePath, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'indices', 'numIndex');
        mbas = mmap;
                
        output = fullfile(dffPath, [num2str(z, '%02d') '.bin']);
        outputInfo = fullfile(dffPath, [num2str(z, '%02d') '.mat']);
        
        fid = fopen(output, 'wb');
        
        tic
        % compute dff
        fwrite(fid,...
            (double(squeeze(msig(indices, z, :))') - mbas.Data.bit(:,:)) ./ ...
                ((mbas.Data.bit(:,:) - background(z))),...
            'double');
        
        toc

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
            'Format',{'double', [t, numIndex],'bit'});
        save(outputInfo, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'indices', 'numIndex');

    end
end
