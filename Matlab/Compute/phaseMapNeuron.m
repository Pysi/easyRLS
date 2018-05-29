function phaseMapNeuron(F, fstim)
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

    % get the layers on which compute phasemap in the RAS order (inferior → superior)
    Zlay = sort(F.Analysis.Layers, 'descend');

    % get path of dff per pixel
    dffPath = F.dir('DFFNeuron');

    % create phasemap folder
    mkdir(F.dir('PhaseMapNeuron'));

    % get path to record data
    labels = {'pmn_amplitude', 'pmn_phase', 'pmn_deltaphi'};% 'pmn_realpart', 'pmn_imaginary'};
    out = struct();
    outInfo = struct();
    for label = labels
        mkdir(F.dir(label{:})); % create corresponding directory
        out.(label{:}) = fopen([F.tag(label{:}) '.bin'], 'wb');
        outInfo.(label{:}) = [F.tag(label{:}) '.mat'];
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

        % Phase shift
        phi_GCaMP = 0;%-0.6916;
        % Phase shift because of the response of the GCaMP, get with the convolution of the stimulus with a Kernel

% % % % % % LOOP % % % % % 
    % run across the layers
    for iz = Zlay
        fprintf('phasemap per neuron for layer %d\t', iz);tic;

        % Phase shift because of the response of the GCaMP, get with the convolution of the stimulus with a Kernel
        phi_layer = iz*(F.dt*2*pi)*fstim*0.001;   % Phase shift because of the delay time between each layer (F.dt)
        phase_delay = phi_GCaMP + phi_layer;         % (pi/2 - 0.8796) Phase shift of sinusodial stimulus

        % Load DFF
        dffLayer = fullfile(dffPath, [num2str(iz, '%02d') '.mat']);
        load(dffLayer, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'centerCoord', 'neuronShape', 'numNeurons');
        mdff = recreateMmap(F,mmap);
        
        % initialize buffer
       	for label = labels
            BUFFER.(label{:}) = zeros(x,y); % a buffer for the layer
        end

        % run across all neurons
        for i = 1:numNeurons % index of neuron in dff

            % Calculate fourier transformation
            Y = fft(mdff.Data.bit(:,i));

            % extract peak from dff
            pmn_amplitude = abs(Y(ind_fstim,:));
            pmn_phase     = angle(Y(ind_fstim,:));
            pmn_realpart  = real(Y(ind_fstim,:));
            pmn_imaginary = imag(Y(ind_fstim,:));
            pmn_deltaphi = (pmn_phase - phase_delay + pi);
                % -phase_delay = Shift positive of the fluorescence
                % +pi = because of the fourier transform is done against a cosinus
                
            
            % fills buffer
            for label = labels
                BUFFER.(label{:})(neuronShape{i}) = eval(label{:}); % a buffer for the layer
            end

        end
        toc;
        
        % write buffer (full layer)
        for label = labels
            fwrite(out.(label{:}), BUFFER.(label{:}), 'single');
        end
    end 
        
    % close binary files and write info (.mat and .nhdr)
    space = 'RAS';
    pixtype = 'single';
    z = length(Zlay); Z = Zlay; % Zlay prevents overwriting by Z
    t = 1; T = 1;
    for label = labels
        fclose(out.(label{:}));
        save(outInfo.(label{:}),'x','y','z','t','Z','T','space','pixtype')
        % TODO write info and nhdr (/!\ on single)
        writeNHDR(F, label{:});
    end
    
end