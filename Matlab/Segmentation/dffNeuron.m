function dffNeuron(F, Layers)
%dffNeuron computes delta f over f for each segmented neuron
% F focus object
% Layers layers you want to compute dff on (ex [3 4 6])

% create dff directory
dffPath = F.dir('DFFNeuron');
disp('creating ''DFFNeuron'' directory'); mkdir(dffPath);

% load background
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
        basePath = fullfile(F.dir('BaselineNeuron'), [num2str(iz, '%02d') '.mat']);
        load(basePath, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'centerCoord', 'neuronShape', 'numNeurons');
        mbas = recreateMmap(F,mmap); clear('mmap');
                
        output = fullfile(dffPath, [num2str(iz, '%02d') '.bin']);
        outputInfo = fullfile(dffPath, [num2str(iz, '%02d') '.mat']);
        
        fid = fopen(output, 'wb');
        
        fprintf('computing dff per neuron for layer %d (%d neurons, %d timeframes)\n', iz, numNeurons, m.t);
        ttt=tic;
        % get signal
        signal = NaN(numNeurons, 1, m.t);
        for in = 1:numNeurons 
            tic; sig = m(neuronShape{in}, iz, :); titi=toc;
            if titi> 0.1 % usually titi should be around 0.001 (100×smaller)
                fprintf('\tgot signal : %.03f s, neuron %d size %d\n', titi, in, length(neuronShape{in}));
            end
            signal(in,1,:) = mean(sig, 1);
        end
        signal = single(permute(squeeze(signal), [2 1]));
        
        % compute dff
        % (signal - baseline) / (baseline - background)
        % single( uint16 - uint16 ) / (single(uint16) - single)
        dff = ( signal - single(mbas.Data.bit(:,:)) ) ./ ...
                ( single(mbas.Data.bit(:,:)) - background(iz) );
        fwrite(fid, dff, 'single');
        toc(ttt);
        fclose(fid);
        
        % clear memory map
        clear('mbas');
        
        % Z is the current z
        Z = iz; 
        
        % create corresponding mmap and clear it
        mmap = memmapfile(output,...
            'Format',{'single', [t, numNeurons],'bit'});
        save(outputInfo, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'centerCoord', 'neuronShape', 'numNeurons');
        clear('mmap');
        
    end
end
