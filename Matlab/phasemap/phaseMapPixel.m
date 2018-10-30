function phaseMapPixel(F)
%phaseMapPixel computes the phase map per pixel using the fft

% inputs
% frequence of stimulation (TODO search in focus / stimulation)
% dff per pixel

% outputs
% amplitude of fft peak
% phase of fft peak
% corrected phase (deltaphi)
% real part of fft peak
% imaginary part of fft peak

% % % % % % % THIS IS A DRAFT VERSION % % % % % % % % %

    % stimulus frequency
    fstim = F.Analysis.StimulusFrequency; % frequency of stimulus

    % get the layers on which compute phasemap in the RAS order (inferior → superior)
    Zlay = sort(F.Analysis.Layers, 'descend'); % as we are writing a binary file, it has to be in the RAS order

    % loads memory maps
    m = Focused.MmapPerLayer(F, 'DFFPixel');

    % create phasemap folder
    Focused.mkdir(F, 'PhaseMapDFFPixel');

    % get path to record data (defines what should be output)
    prefix = 'pmpdff_';
    labels = {'amplitude', 'deltaphi'}; %{'amplitude', 'phase', 'deltaphi', 'realpart', 'imaginary'};
    out = struct();
    outInfo = struct();
    for label = labels
        fulltag = [prefix label{:}]; 
        mkdir(F.dir(fulltag)); % create corresponding directory
        out.(label{:}) = fopen([F.tag(fulltag) '.bin'], 'wb');
        outInfo.(label{:}) = [F.tag(fulltag) '.mat'];
    end
    
    % Define stimulation parameters
    fstim = fstim;                              % Stimulation frequency
    N = F.param.NCycles ;                       % Number of images per layer
    fs = 1000 / (F.dt * F.param.NLayers);       % Frame rate at which images per layer are acquired
    dt = 1/fs;                                  % Sampling period
    T = N*dt;                                   % Total time of acquisition

    % Define frequency vector
    f = fs*[0:1:N/2]/N;

    % Finds the peak at the given frequency
    f_round = round(f,3);
    ind_fstim = find(f_round==fstim);
    fprintf("found index of fstim : %d\n", ind_fstim);
    
    picWidth = 3;
    windowWidth = 20;
    wsm = ind_fstim - picWidth; % window start minus
    wsp = ind_fstim + picWidth; % window start plus
    wem = wsm - windowWidth; % window end minus
    wep = wsp + windowWidth; % window end plus
    noiseWindow = [wsm:-1:wem, wsp:1:wep];
    fprintf("noise window between %d - %d and %d %d\n", wem, wsm, wsp, wep);


    % Phase shift
    phi_GCaMP = 0;%-0.6916;
    % Phase shift because of the response of the GCaMP, get with the convolution of the stimulus with a Kernel
    


% % % % % % LOOP % % % % % 
    % run across the layers
    for iz = Zlay
        fprintf('\nphasemap per pixel for layer %d\t', iz);tic;

        % focus on the current layer
        % F.select(iz); % this is not useful anymore, and does not work when no tif

        % Phase shift because of the response of the GCaMP, get with the convolution of the stimulus with a Kernel
        phi_layer = iz*(F.dt*2*pi)*fstim*0.001;   % Phase shift because of the delay time between each layer (F.dt)
        phase_delay = phi_GCaMP + phi_layer;         % (pi/2 - 0.8796) Phase shift of sinusodial stimulus

        % creates a buffer to write phasemap for each label
       	for label = labels
            BUFFER.(label{:}) = zeros(m.x,m.y); % a buffer for the layer
        end
        
        % run across all image pixels
        for i = 1:m.numIndex{iz}
            index = m.indices{iz}(i);
            % Calculate fourier transformation
            Y = fft(m.mmaps{iz}.Data.bit(:, i));

            % extract peak from dff
            amplitude = abs(Y(ind_fstim,:));
            phase     = angle(Y(ind_fstim,:));
            realpart  = real(Y(ind_fstim,:));
            imaginary = imag(Y(ind_fstim,:));
            deltaphi  = (phase - phase_delay + pi);
                % -phase_delay = Shift positive of the fluorescence
                % +pi = because of the fourier transform is done against a cosinus
                
            % noise correction
            noise = mean(abs(Y(noiseWindow)));
            amplitude = (amplitude - noise);
            % TODO reste
                
            % fills buffer
            for label = labels
                BUFFER.(label{:})(index) = eval(label{:}); % a buffer for the layer
            end
        end
        
        % write buffers in binary files
        for label = labels 
            fwrite(out.(label{:}), BUFFER.(label{:}), 'single'); 
        end 
        
        toc;
        
    end 
        
    % close binary files and write info (.mat and .nhdr)
    z = length(Zlay); Z = Zlay; % Zlay prevents overwriting by Z
    t = 1; T = 1;
    for label = labels
        fulltag = [prefix label{:}];
        fclose(out.(label{:}));
        writeINFO(outInfo.(label{:}), m.x, m.y, z, t, Z, T, 'RAS', 'single')
        % TODO write info and nhdr (/!\ on single)
        writeNHDR(F, fulltag);
    end
    
end