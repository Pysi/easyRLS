function phaseMapPixel_PerPackage_v2(F)
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

% load stimulus data
%% Load stimulus data
filename = fullfile( F.dir('Run'), 'Stimulus.txt') ;%'/home/ljp/Science/Projects/RLS/Data/2018-06-14/Run 19/Stimulus.txt';
delimiter = '\t';
formatSpec = '%*q%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);
Time = dataArray{:, 1};
Motor = dataArray{:, 2};
clearvars filename delimiter formatSpec fileID dataArray ans;

Timewindow = [824,-24];%Seconde
TimewindowDFF = [2061,2940];%Frame

% Interpolate and plot stimulus data
% interpolate Stimulus signal at the image acquisition frequency (for example 50Hz)
Time = (Time - Time(1)) + 0.14;  % time in seconds   % the added constant is the time when the first motor position is recorded. The motor is acquired at 10Hz. The extra 40ms were added to best overlay the motor signal with a -cos function, which is our control signal
Tq = linspace(0.012+Timewindow(1),1199.99+Timewindow(2),20000); %
Motor_inter  = interp1(Time,Motor,Tq,'spline');

%%
Time = Tq;% clear Tq;

N = length(Motor_inter)
f = 1/(F.dt/1000)*[0:1:N/2]/N;

% Yfft=fft(Motor);
% figure
% plot(f,abs(Yfft(1:N/2+1)))


% stimulus frequency
fstim = F.Analysis.StimulusFrequency; % frequency of stimulus

% get the layers on which compute phasemap in the RAS order (inferior → superior)
Zlay = sort(F.Analysis.Layers, 'descend'); % as we are writing a binary file, it has to be in the RAS order

% get path of dff per pixel
dffPath = F.dir('DFFPixel');

% create phasemap folder
%Focused.mkdir(F, 'PhaseMapPixel');

Focused.mkdir(F, 'PhaseMapDFFPixel');



% get path to record data (defines what should be output)
prefix = 'pmpdff_';
labels = {'amplitude', 'phase', 'deltaphi', 'realpart', 'imaginary'};
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
%     N = F.param.NCycles;                       % Number of images per layer
N = TimewindowDFF(2) - TimewindowDFF(1);
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
    
    % creates a buffer to write phasemap for each label
    for label = labels
        BUFFER.(label{:}) = zeros(x,y); % a buffer for the layer
    end
    %         %%%%%%%%%%%%%%%%%% original
    %         i = 0;
    %         % run across all image pixels
    %         for index = indices'
    %             i = i + 1;
    %             % Calculate fourier transformation
    %             Y = fft(mdff.Data.bit(:, i));
    %
    %             % extract peak from dff
    %             amplitude = max(abs(Y));
    %             phase     = angle(Y(ind_fstim,:));
    %             realpart  = real(Y(ind_fstim,:));
    %             imaginary = imag(Y(ind_fstim,:));
    %             deltaphi  = (phase - phase_delay + pi);
    %                 % -phase_delay = Shift positive of the fluorescence
    %                 % +pi = because of the fourier transform is done against a cosinus
    %
    %             % fills buffer
    %             for label = labels
    %                 BUFFER.(label{:})(index) = eval(label{:}); % a buffer for the layer
    %             end
    %         end
    %%%%%%%%%%%%%%%%%% new per package
    
    i = 0;
    % run across all image pixels
    packageSize = 10;
    index = indices';
    for k = 1 : packageSize
        I = indices * 0;
        I(k:packageSize:end) = 1;
        i = find(I);
        
        
        % %             % calculate deltaphi via hilbert transform
        Stim = Motor_inter(iz:20:end)';
        Stim_fft = fft(Stim);
        % figure;plot(abs(Stim_fft));  % max at 234  241  245
        real_stim_fft = abs(Stim_fft);
        [peak_height, peak_ind] = max(real_stim_fft(1:round(0.5*length(real_stim_fft))));
        phase_stim = angle(Stim_fft(peak_ind));
        
        %%
        % [Motormin_amp, Motormin_inds] = findpeaks(-Motor_inter);
        %
        % first_minimum_ind = Motormin_inds(1);
        % % plot(Tq, Motor_inter);
        % % hold on;
        % % plot(Tq(Motormin_inds(1)), Motor_inter(Motormin_inds(1)), '*');
        %
        % fp_inds= peak_ind;
        % frequency_tw = f(fp_inds);
        %
        % % Phase of the stimulus
        % phase_stim = angle(Stim_fft(fp_inds));
        %
        % time_offset_tw = Tq(Motormin_inds(1)) - Tq(1);
        % ph_offset_tw = 2 * pi * frequency_tw * time_offset_tw;
        %
        % phase_stim + ph_offset_tw
        
        % [ifreq, itime] = instfreq(Motor, Time);
        % plot(itime, ifreq)
        % %%
        % n_times = length(Time)
        % Time(round(n_times / 3))
        % Time(round(2 * n_times / 3))
        
        %%
        % simulate
        testtime = linspace(0, 20, 2000); % 10 periods
        testfreq = 0.25;
        testph_stimulus = 0;
        testph_neuron = 0.3;
        testsignal_stimulus = cos(2 * pi * testfreq * testtime + testph_stimulus);% + 0.1*randn(size(testtime));
        testsignal_neuron = cos(2 * pi * testfreq * testtime + testph_neuron);% + 0.1*randn(size(testtime));
        
        testfft_stimulus = fft(testsignal_stimulus);
        
        testfft_neuron = fft(testsignal_neuron);
        % plot(abs(testfft))
        
        [testpeak_height_stimulus, testpeak_ind_stimulus] = max(testfft_stimulus(1:round(0.5*length(testfft_stimulus))));
        [testpeak_height_neuron, testpeak_ind_neuron] = max(testfft_neuron(1:round(0.5*length(testfft_neuron))));
        testangle_stimulus= angle(testfft_stimulus(testpeak_ind_stimulus))
        testangle_neuron= angle(testfft_neuron(testpeak_ind_neuron))
        
        testphasedelay =  (testangle_neuron - testangle_stimulus)
        % [testsignalmins, testsignalmininds] = findpeaks(-testsignal);
        % testtime_offset_tw = testtime(testsignalmininds(1)) - testtime(1);
        % testph_offset_tw = 2 * pi * testfreq * testtime_offset_tw
        
        plot(testtime, testsignal_stimulus, 'r', testtime, testsignal_neuron, 'b')
        legend('stimulus', 'neuron')
         
        %% simulate
%         testtime = linspace(0, 20, 2000); % 10 periods
%         testfreq = 0.5;
%         testph_stimulus = 0;
%         testph_neuron = -0.3;
%         testsignal_stimulus = cos(2 * pi * testfreq * testtime + testph_stimulus);% + 0.1*randn(size(testtime));
%         testsignal_neuron = cos(2 * pi * testfreq * testtime + testph_neuron);% + 0.1*randn(size(testtime));
%         
%         testfft_stimulus = fft(testsignal_stimulus);
%         
%         testfft_neuron = fft(testsignal_neuron);
%         % plot(abs(testfft))
%         
%         [testpeak_height_stimulus, testpeak_ind_stimulus] = max(testfft_stimulus(1:round(0.5*length(testfft_stimulus))));
%         [testpeak_height_neuron, testpeak_ind_neuron] = max(testfft_neuron(1:round(0.5*length(testfft_neuron))));
%         testangle_stimulus= angle(testfft_stimulus(testpeak_ind_stimulus))
%         testangle_neuron= angle(testfft_neuron(testpeak_ind_neuron))
%         
%         testphasedelay =  (testangle_stimulus - testangle_neuron)
%         % [testsignalmins, testsignalmininds] = findpeaks(-testsignal);
%         % testtime_offset_tw = testtime(testsignalmininds(1)) - testtime(1);
%         % testph_offset_tw = 2 * pi * testfreq * testtime_offset_tw
%         
%         plot(testtime, testsignal_stimulus, 'r', testtime, testsignal_neuron, 'b')
%         legend('stimulus', 'neuron')
% %         

        %%
        %             Stim_h = hilbert(Stim);
        %             Y_h = hilbert(mdff.Data.bit(:, i)');
        %             phase_Stim_h = unwrap(angle(Stim_h));
        %             phase_Y_h    = unwrap(angle(Y_h));
        %
        %             deltaphi = mean(phase_Y_h - phase_Stim_h);
        
        % Calculate fourier transformation
        Y = fft(mdff.Data.bit(TimewindowDFF(1):TimewindowDFF(2), i),[],1);
        
        Y1 = abs(Y);
        Y1m = mean(Y1([200:650],:),1);
        Y1s = std(Y1([200:650],:),[],1);
        %Y1 = (Y1-Y1m)./Y1s;
        Y1 = (Y1-Y1m)./Y1m;
        
        ind_fstim = peak_ind;
        
        % extract peak from dfff
        %amplitude = max(abs(Y));
        amplitude = abs(Y1(ind_fstim,:));
        phase     = angle(Y(ind_fstim,:));
        %  realpart  = real(Y(ind_fstim,:));
        %  imaginary = imag(Y(ind_fstim,:));
        %deltaphi  = (phase - phase_delay + pi + ph_offset_tw);   %% (phase - phase_delay*(0.2./frequency_tw) + pi + ph_offset_tw);
        %deltaphi = (phase_stim - phase - phase_delay);
        deltaphi = (phase -phase_stim -  phase_delay);
        realpart  = real(amplitude.*exp(j.*deltaphi));
        imaginary = imag(amplitude.*exp(j.*deltaphi));
        
        % -phase_delay = Shift positive of the fluorescence
        % +pi = because of the fourier transform is done against a cosinus
        
        % fills buffer
        for label = labels
            BUFFER.(label{:})(index(i)) = eval(label{:}); % a buffer for the layer
        end
    end
    
    %         %%%%%%%%%%%%%%%%% template from calculation on signal
    %
    %              % run across all image pixels
    %         for k = 1:10
    %              i = indices(k:10:end)' ;
    %                 % Calculate fourier transformation
    %     %             tic;Y = fft(squeeze(m(i,iz,:)));if toc > 0.01; toc; end
    %                 tic; ysig = single(squeeze(m(i,iz,:))); if toc > 0.1; toc; end
    %                 y_zscore = (ysig - nanmean(ysig,2)) ./ std(ysig,[],2);
    %
    %                 Y = fft(y_zscore,[],2);
    %
    %
    %                 % calculate response amplitude
    %                 %     [pxx_p,f_p] = periodogram(DFF_pix(:,1:L)',hamming(L),[fstim fstim*2]',fs,'power');
    %                 %     amplitude = sqrt(pxx_p(1,:)*2*2);
    %                 [pxx,ff] = periodogram(y_zscore',hamming(m.t),m.t,fs,'power');
    %                 pxx_p = pxx((single(ff) == single(fstim)),:);
    %                 amplitude = sqrt(pxx_p(1,:)*2)*2; % amplitude peak-to-peak
    %
    %                 % extract peak from dff
    %                  amplitude = abs(Y(:,ind_fstim));
    %                 phase     = angle(Y(:,ind_fstim));
    %                 realpart  = real(Y(:,ind_fstim));
    %                 imaginary = imag(Y(:,ind_fstim));
    %
    %                 deltaphi  = (phase - phase_delay + pi);
    %                     % -phase_delay = Shift positive of the fluorescence
    %                     % +pi = because of the fourier transform is done against a cosinus
    %
    %                 % fills buffer
    %                 for label = labels
    %                     BUFFER.(label{:})(i) = eval(label{:}); % a buffer for the layer
    %                 end
    %
    %         end
    %
    %         %%%%%%%%%%%%%%%%%%%%%%%%
    
    % write buffers in binary files
    for label = labels
        fwrite(out.(label{:}), BUFFER.(label{:}), 'single');
    end
    
    toc;
    
end

% close binary files and write info (.mat and .nhdr)
space = 'RAS';
pixtype = 'single';
z = length(Zlay); Z = Zlay; % Zlay prevents overwriting by Z
t = 1; T = 1;
for label = labels
    fulltag = [prefix label{:}];
    fclose(out.(label{:}));
    save(outInfo.(label{:}),'x','y','z','t','Z','T','space','pixtype')
    % TODO write info and nhdr (/!\ on single)
    writeNHDR(F, fulltag);
end

end