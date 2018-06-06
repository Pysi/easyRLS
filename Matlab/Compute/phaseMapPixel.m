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
    Zlay = sort(F.Analysis.Layers, 'descend');

    % get path of dff per pixel
    dffPath = F.dir('DFFPixel');

    % create phasemap folder
    mkdir(F.dir('PhaseMapPixel'));

    % get path to record data
    labels = {'pmp_amplitude', 'pmp_phase', 'pmp_deltaphi', 'pmp_realpart', 'pmp_imaginary'};
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
        fprintf('\nphasemap per pixel for layer %d\t', iz);tic;

        % focus on the current layer
        % F.select(iz); % this is not useful anymore, and does not work when no tif

        % Phase shift because of the response of the GCaMP, get with the convolution of the stimulus with a Kernel
        phi_layer = iz*(F.dt*2*pi)*fstim*0.001;   % Phase shift because of the delay time between each layer (F.dt)
        phase_delay = phi_GCaMP + phi_layer;         % (pi/2 - 0.8796) Phase shift of sinusodial stimulus

        % Load DFF
        dffLayer = fullfile(dffPath, [num2str(iz, '%02d') '.mat']);
        load(dffLayer, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'indices', 'numIndex');
        mdff = recreateMmap(F,mmap);

        % run across all image pixels
        index = 0; % number of index in dff
        zerosToWrite = 0;
        for i = 1:x*y

            %if index is not in ROI (could check directly with mask, but mask could have changed)
            if ~max(ismember(indices,i))
                zerosToWrite = zerosToWrite +1;
            %else index is in ROI and DFF is defined
            else
                index = index + 1; % increment by one
                % write all zeros at the same time
                for label = labels
                    fwrite(out.(label{:}), zeros(1,zerosToWrite), 'single');
                end
                zerosToWrite = 0;
                
                % Calculate fourier transformation
                Y = fft(mdff.Data.bit(:,index));

                % extract peak from dff
                pmp_amplitude = abs(Y(ind_fstim,:));
                pmp_phase     = angle(Y(ind_fstim,:));
                pmp_realpart  = real(Y(ind_fstim,:));
                pmp_imaginary = imag(Y(ind_fstim,:));
                pmp_deltaphi = (pmp_phase - phase_delay + pi);
                    % -phase_delay = Shift positive of the fluorescence
                    % +pi = because of the fourier transform is done against a cosinus  

                % write pixel in all binaries
                for label = labels
                    fwrite(out.(label{:}), eval(label{:}), 'single');
                end

            end

        end
        % write remaining zeros
        for label = labels
            fwrite(out.(label{:}), zeros(1,zerosToWrite), 'single');
        end
        toc;
        
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