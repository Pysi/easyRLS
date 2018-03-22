function caToolsRunquantileLin_BENCHMARK(F, Layers)
%caToolsRunquantile computes running quantile using caTools
% loop for each index
% takes less memory (but more time ?)

    global COMPUTING
    global WRITING

    baselinePath = fullfile(F.dir.IP, 'baseline');
    disp('creating ''baseline'' directory'); mkdir(baselinePath);
        
    m = Focused.Mmap(F, 'corrected');
    
    for z = Layers
        
        output = fullfile(baselinePath, [num2str(z, '%.03d') '.bin']);
        outputInfo = fullfile(baselinePath, [num2str(z, '%.03d') '.mat']);

        tic;indices = maskToIndex(F, z);fprintf('creating indexes from mask: %.02f s\n', toc);
        numIndex = length(indices);
        
        fprintf('computing baseline for layer %d (%d points)\n', z, numIndex)
        
        OUT = NaN(m.t, 1);
        fid = fopen(output, 'wb');
        
        COMPUTING = NaN(size(indices'));
        WRITING = NaN(size(indices'));
            
        for i = indices' % loop for each index
            tic;
            [~, OUT] = calllib('caTools', 'runquantile',...
                    squeeze(m(i, z, :)),... input matrix (t, index)
                    OUT,... output variable
                    m.t,... size of input matrix
                    100,... window
                    0.1,... quantile
                    1,... lenght of quantile vector (here only one)
                    1 ... type of quantile calculation
                    );
%             fprintf('calling runquantile: %.03f s\n', toc);
            COMPUTING(i) = toc;

            % write baseline to binary file (seems that cast to double is operated by matlab)
            tic; 
            fwrite(fid,...
                OUT,...
                'double');
%             fprintf('writing to binary file: %02f s\n', toc);
            WRITING(i) = toc;
        end
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
            'Format',{'double', [t, numIndex],'bit'});
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
