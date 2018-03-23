function caToolsRunquantileLin_BENCHMARK(F, Layers)
%caToolsRunquantile computes running quantile using caTools
% loop for each index
% takes less memory (but more time ?)

	global LOADING
    global COMPUTING
    global WRITING

    baselinePath = fullfile(F.dir.IP, 'baseline');
    disp('creating ''baseline'' directory'); mkdir(baselinePath);
        
    m = Focused.Mmap(F, 'corrected');
    
    for z = Layers
        
        output = fullfile(baselinePath, [num2str(z, '%.02d') '.bin']);
        outputInfo = fullfile(baselinePath, [num2str(z, '%.02d') '.mat']);

        tic;indices = maskToIndex(F, z);fprintf('creating indexes from mask: %.02f s\n', toc);
        numIndex = length(indices);
        
        fprintf('computing baseline for layer %d (%d points, %d timeframes)\n', z, numIndex, m.t)
        
        OUT = NaN(m.t, 1);
        fid = fopen(output, 'wb');
        start_time = tic;
        
        COMPUTING = NaN(size(indices'));
        WRITING = NaN(size(indices'));
            
        for i = indices' % loop for each index
            tic; IN = squeeze(m(i, z, :)); LOADING(i) = toc;
            tic; [~, OUT] = calllib('caTools', 'runquantile',...
                    IN,... input matrix (t, index)
                    OUT,... output variable
                    m.t,... size of input matrix
                    100,... window
                    0.1,... quantile
                    1,... lenght of quantile vector (here only one)
                    1 ... type of quantile calculation
                    ); COMPUTING(i) = toc;

            % write baseline to binary file (seems that cast to double is operated by matlab)
            tic; fwrite(fid,...
                OUT,...
                'uint16'); WRITING(i) = toc;
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
