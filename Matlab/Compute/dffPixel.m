function dffPixel(F, Layers)
%dffPixel computes delta f over f
% F focus object
% Layers layers you want to compute dff on (ex [3 4 6])

% create dff directory
dffPath = F.dir('DFFPixel');
disp('creating ''dff_pixel'' directory'); mkdir(dffPath);

% load background and convert to uint16
load(F.tag('background'), 'background');

% sigstack (x,y,z,t) ((xy,z,t))
m = Focused.Mmap(F, 'corrected');
        
% get values
x = m.x; %#ok<*NASGU>
y = m.y;
z = 1; % only one layer concerned
t = m.t;
% Z = iz; % will be set at the end
T = m.T;

    for iz = Layers

        % basestack (t, xy)
        basePath = fullfile(F.dir('BaselinePixel'), [num2str(iz, '%02d') '.mat']);
        load(basePath, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'indices', 'numIndex');
        mbas = recreateMmap(F,mmap);
                
        output = fullfile(dffPath, [num2str(iz, '%02d') '.bin']);
        outputInfo = fullfile(dffPath, [num2str(iz, '%02d') '.mat']);
        
        fid = fopen(output, 'wb');
        
        tic
        % compute dff
        % (signal - baseline) / (baseline - background)
        % single( uint16 - uint16 ) / (single(uint16) - single)
        fwrite(fid,...
            single( squeeze(m(indices, iz, :))' - mbas.Data.bit(:,:) ) ./ ...
                ( single(mbas.Data.bit(:,:)) - background(iz) ),...
            'single');
        
        fprintf('computing dff per pixel for layer %d: %.02f s\n', iz, toc)
        fclose(fid);
        
        % clear memory map
        clear('mbas');
        
        % Z is the current z
        Z = iz; 
        
        % create corresponding mmap info
        mmap = memmapfile(output,...
            'Format',{'single', [t, numIndex],'bit'});
        save(outputInfo, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'indices', 'numIndex');
        clear('mmap');

    end
end
