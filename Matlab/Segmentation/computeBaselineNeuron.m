function computeBaselineNeuron(F)
%computeBaselineNeuron computes baseline per neuron
% Layers are the layers you want to compute the baseline on
% window is the window span in seconds (ex 50 sec)

    % window
    window = F.Analysis.BaselineWindow; % window is the window span in seconds (ex 50 sec)
    dt = F.dt / 1000 * F.param.NLayers ; % time between two frames of one layer in seconds (ex 0.02 * 20)
    % ignores the delay long
    w = floor(window / dt) ; % number of frames of the window (ex 125 frames)

    % quantile
    q = F.Analysis.BaselinePercentile / 100; % percentile
    
    baselinePath = F.dir('BaselineNeuron');
    Focused.mkdir(F, 'BaselineNeuron');
    segPath = F.dir('Segmentation');
        
    % sigstack (x,y,z,t) ((xy,z,t))
    m = Focused.Mmap(F, 'corrected');

    % get values
    x = m.x; %#ok<*NASGU>
    y = m.y;
    z = 1; % only one layer concerned
    t = m.t;
    % Z = iz; % will be set at the end
    T = m.T;
    
    for iz = m.Z
        inputSeg = fullfile(segPath, [num2str(iz, '%02d') '.mat']);
        
        output = fullfile(baselinePath, [num2str(iz, '%02d') '.bin']);
        outputInfo = fullfile(baselinePath, [num2str(iz, '%02d') '.mat']);

        load(inputSeg, 'centerCoord', 'neuronShape');
        ns = neuronShape;
        numNeurons = length(ns);
        
        fprintf('computing baseline per neuron for layer %d (%d points, %d timeframes)\n', iz, numNeurons, m.t)
        
        OUT = NaN(m.t, 1);
        fid = fopen(output, 'wb');
        start_time = tic;
            
        for i = 1:numNeurons % loop over each neuron ~10000 neurons instead of ~300000 pixels
            IN = squeeze(mean(m(ns{i}, iz, :), 1)); % call memory map with linear indexing
            [~, OUT] = calllib('caTools', 'runquantile',...
                    IN,... input matrix (t, index)
                    OUT,... output variable
                    m.t,... size of input matrix
                    w,... window
                    q,... quantile
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
            'Format',{'uint16', [t, numNeurons],'bit'});
        save(outputInfo, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'centerCoord', 'neuronShape', 'numNeurons');
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
