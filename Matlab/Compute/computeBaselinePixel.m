function computeBaselinePixel(F)
%computeBaselinePixel computes running quantile using caTools runquantile

    % layers to analyse % Layers are the layers you want to compute the baseline on
    Layers = F.Analysis.Layers;

    % window
    window = F.Analysis.BaselineWindow; % window is the window span in seconds (ex 50 sec)
    dt = F.dt / 1000 * F.param.NLayers ; % time between two frames of one layer in seconds (ex 0.02 * 20)
    % ignores the delay long
    w = floor(window / dt) ; % number of frames of the window (ex 125 frames)

    baselinePath = F.dir('BaselinePixel');
    disp('creating ''BaselinePixel'' directory'); mkdir(baselinePath);
        
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
        
        output = fullfile(baselinePath, [num2str(iz, '%02d') '.bin']);
        outputInfo = fullfile(baselinePath, [num2str(iz, '%02d') '.mat']);

        indices = maskToIndex(F, iz);
        numIndex = length(indices);
        
        fprintf('computing baseline per pixel for layer %d (%d points, %d timeframes)\n', iz, numIndex, m.t)
        
        OUT = NaN(m.t, 1);
        fid = fopen(output, 'wb');
        start_time = tic;
            
        for i = indices' % loop for each index
            IN = squeeze(m(i, iz, :));
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
        
        % Z is the current z
        Z = iz; 

        % create corresponding mmap info
        mmap = memmapfile(output,...
            'Format',{'uint16', [t, numIndex],'bit'});
        save(outputInfo, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'indices', 'numIndex');
        clear('mmap');
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
