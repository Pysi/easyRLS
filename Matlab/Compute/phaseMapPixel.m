function phaseMapPixel(F, fstim)
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

    % get the layers on which compute phasemap in the RAS order (inferior → superior)
    Z = sort(F.Analysis.Layers, 'descend');

    % get path of dff per pixel
    dffPath = F.dir('DFFPixel');

    % create phasemap folder
    mkdir(F.dir('PhaseMap'));

    % get path to record data
    labels = {'amplitude', 'phase', 'deltaphi', 'realpart', 'imaginary'};
    out = struct();
    outInfo = struct();
    for label = labels
        mkdir(F.dir(label)); % create corresponding directory
        out.(label) = fopen([F.tag(label) '.bin']);
        outInfo.(label) = [F.tag(label) '.mat'];
    end

    % run across the layers
    for iz = Z

        % focus on the current layer
        F.select(iz);

        % Define stimulation parameters
        fstim = fstim;                              % Stimulation frequency
        N = F.param.NCycles ;                       % Number of images per layer
        fs = 1/(F.dt*0.001*size(F.sets, 2));        % Frame rate at which images per layer are acquired
        dt = 1/fs;                                  % Sampling period
        T = N*dt;                                   % Total time of acquisition

        % Phase shift
        phi_GCaMP = 0;%-0.6916;                      % Phase shift because of the response of the GCaMP, get with the convolution of the stimulus with a Kernel
        phi_layer = layer*(F.dt*2*pi)*fstim*0.001;   % Phase shift because of the delay time between each layer (F.dt)
        phase_delay = phi_GCaMP + phi_layer;         % (pi/2 - 0.8796) Phase shift of sinusodial stimulus

        % Load DFF
        dffLayer = fullfile(dffPath, [num2str(iz, '%02d') '.mat']);
        load(dffLayer, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'indices', 'numIndex');
        mdff = recreateMmap(F,mmap);

        % run across all image pixels
        for index = 1:x*y

            %if index is not in ROI (could check directly with mask, but mask could have changed)
            if ~max(ismember(indices,index))
                % write zero
                for label = labels
                    fwrite(out.(label), 0, 'single');
                end
            %else index is in ROI and DFF is defined
            else
                % do stuff

                % Calculate fourier transformation
                Y = fft(mdff(:,index));

                % Define frequency vector
                f = fs*[0:1:N/2]/N;

                % Extract amplitude and phase of DFF response
                f_round = round(f,3);
                ind_fstim = find(f_round==fstim);

                % extract peak from dff
                amplitude = abs(Y(:,ind_fstim));
                phase     = angle(Y(:,ind_fstim));
                realpart  = real(Y(:,ind_fstim));
                imaginary = imag(Y(:,ind_fstim));
                deltaphi = (phi - phase_delay + pi);
                    % -phase_delay = Shift positive of the fluorescence
                    % +pi = because of the fourier transform is done against a cosinus  

                % write pixel in binaries
                for label = labels
                    fwrite(out.(label), eval(label), 'single')
                end

            end

        end
        
        % close binary files
        for label = labels
            fclose(out.(label));
        end
        
        % TODO write info and nhdr (/!\ on single)

    end

end