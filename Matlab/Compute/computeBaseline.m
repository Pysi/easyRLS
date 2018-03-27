function computeBaseline(F, Layers, window)
%computeBaseline computes running quantile using caTools runquantile
% Layers are the layers you want to compute the baseline on
% window is the window span in seconds (ex 50 sec)

    % window
    dt = F.dt / 1000 * F.param.NLayers ; % time between two frames of one layer in seconds (ex 0.02 * 20)
    % ignores the delay long
    w = floor(window / dt) ; % number of frames of the window (ex 125 frames)

    baselinePath = fullfile(F.dir.IP, 'baseline');
    disp('creating ''baseline'' directory'); mkdir(baselinePath);
        
    m = Focused.Mmap(F, 'corrected');
    
    for z = Layers
        
        output = fullfile(baselinePath, [num2str(z, '%02d') '.bin']);
        outputInfo = fullfile(baselinePath, [num2str(z, '%02d') '.mat']);

        indices = maskToIndex(F, z);
        numIndex = length(indices);
        
        fprintf('computing baseline for layer %d (%d points, %d timeframes)\n', z, numIndex, m.t)
        
        OUT = NaN(m.t, 1);
        fid = fopen(output, 'wb');
        start_time = tic;
            
        for i = indices' % loop for each index
            IN = squeeze(m(i, z, :));
            [~, OUT] = calllib('caTools', 'runquantile',...
                    IN,... input matrix (t, index)
                    OUT,... output variable
                    m.t,... size of input matrix
                    w,... window
                    0.1,... quantile
                    1,... lenght of quantile vector (here only one)
                    1 ... type of quantile calculation
                    );

            % write baseline to binary file (seems that cast to double is operated by matlab)
            fwrite(fid,...
                OUT,...
                'uint16');
        end
            
        toc(start_time)
        fclose(fid);
        
        % get values
        x = m.x;     %#ok<*NASGU>
        y = m.y;   
        % z
        t = m.t;
        Z = z;
        T = m.T;

        % create corresponding mmap info
        mmap = memmapfile(output,...
            'Format',{'uint16', [t, numIndex],'bit'});
        save(outputInfo, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'indices', 'numIndex');
    end
end

% MORE

% libfunctions('caTools') 	% to know available functions
% libfunctions caTools -full 	% to learn more about these functions
% ... function signature
% [doublePtr, doublePtr, int32Ptr, int32Ptr, doublePtr, int32Ptr, int32Ptr]
% runquantile(doublePtr, doublePtr, int32Ptr, int32Ptr, doublePtr, int32Ptr, int32Ptr)
% ... function syntax
% OUT = calllib('caTools', 'runquantile', IN, OUT, 1500, 100, 0.1, 1, 1);
