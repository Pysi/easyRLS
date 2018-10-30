function phaseMapPixel_PerPackage(F)
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

%% Load stimulus data
%'/home/ljp/Science/Projects/RLS/Data/2018-06-14/Run 19/Stimulus.txt';
[Time, Motor] = getStimulusData(fullfile( F.dir('Run'), 'Stimulus.txt'));

% Interpolate and plot stimulus data
% interpolate Stimulus signal at the image acquisition frequency (for example 50Hz)
%Time = (Time - Time(1)) + 0.14;  % time in seconds   % the added constant is the time when the first motor position is recorded. The motor is acquired at 10Hz. The extra 40ms were added to best overlay the motor signal with a -cos function, which is our control signal

fstim = F.Analysis.StimulusFrequency; % frequency of stimulus
Motor_time_offset = acos( Motor(1) / -10)*(1/(2*pi*fstim) ); % Compute the time motor offset, when the first motor position is recorded.
Time = (Time - Time(1)) + Motor_time_offset;  % time in seconds   % The added constant is the time when the first motor position is recorded. The motor is acquired at 10Hz. The extra 40ms were added to best overlay the motor signal with a -cos function, which is our control signal

% If the Time vector has two equal values
for i = 2:size(Time,1)
    if Time(i) == Time(i-1)
        Time(i) = Time(i) + 0.001;
    end
end

%Tq = linspace(0.012,1199.988,60000);
Tq = (F.param.Exposure + F.param.Delay)/1000 : (F.param.Exposure + F.param.Delay)/1000 : F.param.CycleTime; 
if Motor(1) > -10
Time2 = [0; Time]; % We add the fisrt time point in order to get a motor trace which begin at time 0, as the recording of the activity.
Motor2 = [-10; Motor]; % We add the fisrt time point in order to get a motor trace which begin at time 0, as the recording of the activity.
Motor_inter = interp1(Time2,Motor2,Tq,'spline');
else
   Motor_inter = interp1(Time,Motor,Tq,'spline'); 
end
clear Tq;
%%
% get the layers on which compute phasemap in the RAS order (inferior → superior)
Zlay = sort(F.Analysis.Layers, 'descend'); % as we are writing a binary file, it has to be in the RAS order

% get path of dff per pixel
dffPath = F.dir('DFFPixel');
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

% % % % % % LOOP % % % % %
% run across the layers
for iz = Zlay
    fprintf('\nphasemap per pixel for layer %d\t', iz);tic;
    
    % Load DFF
    dffLayer = fullfile(dffPath, [num2str(iz, '%02d') '.mat']);
    load(dffLayer, 'mmap', 'x', 'y', 'z', 't', 'Z', 'T', 'indices', 'numIndex');
    mdff = recreateMmap(F,mmap);
    
    % creates a buffer to write phasemap for each label
    for label = labels
        BUFFER.(label{:}) = zeros(x,y); % a buffer for the layer
    end
    
    i = 0;
    % run across all image pixels
    packageSize = 10;
    index = indices';
    
    % Time Windows
     Windows{1} = [1:1000];
%      Windows{2} = [1051:1950];
%      Windows{3} = [2051:2950];
%    Windows{1} = [1:3000];
    
    for k = 1 : packageSize
        
        I = indices * 0;
        I(k:packageSize:end) = 1;
        i = find(I);
        
        phase_Stim_fw = zeros(size(Windows,2),1);
        phase_DFF_fft_fw = zeros(size(Windows,2),size(i,1));
        f_Stim_tw = zeros(size(Windows,2),1);
        deltaphi_fw = zeros(size(Windows,2),size(i,1));
        Y2 = zeros(size(Windows,2),size(i,1));
        
        for TW = 1:size(Windows,2)
            
            % FFT of the stimulus for a specific time window
            Stim = Motor_inter(iz:20:end)';
            Stim_fft = fft(Stim(Windows{TW}));
            realStim_fft = abs(Stim_fft);
            
            % Find the pic of the frequency of the stimulus on the fourier spectrum
            [pks fw_index] = findpeaks(realStim_fft(1:end/2),'MinPeakHeight',1200);
            if size(fw_index,1) > 1
                disp(['##### WARNING: There is not one pic (', num2str(size(fw_index,1)), ' pics) in the time window selected, select an other time window. #####']);
            end
            phase_Stim_fw(TW) = angle(Stim_fft(fw_index));
            N = length(Windows{TW});
            
            % Find the real frequency of the stimulus
            fs = 1000 / (F.dt * F.param.NLayers); % Frame rate at which images per layer are acquired
            f_window = fs*[0:1:N/2]/N;
            f_Stim_tw(TW) = f_window(fw_index)';
            
            % FFT of the DFF for a specific time window
            DFF_fft = fft(mdff.Data.bit(Windows{TW}, i),[],1);
            phase_DFF_fft_fw(TW,:) = angle(DFF_fft(fw_index,:)) ;
            
            % Compute the phase delay between the stimulus and the DFF
            deltaphi_fw(TW,:) = phase_DFF_fft_fw(TW,:) - phase_Stim_fw(TW);
            
            % Compute the Ampliture with the deniosing
            Y1 = abs(DFF_fft);
%             figure; plot(fftshift(Y1));
            %window_noise = [200:650];
            %window_noise = [40:60 80:110];
            window_noise = [80:200];
            %window_noise = [100:200 300:400];
            %window_noise = [100:200 300:400 550:650];
            Y1m = mean(Y1(window_noise,:),1);
            Y1 = (Y1-Y1m)./Y1m;
            Y2(TW,:) = Y1(fw_index,:);
            
            %clear Y1m DFF_fft f_window fw_index
        end
        
        Z = Y2.*( cos(deltaphi_fw)  + j *sin(deltaphi_fw)   ) ;
        
        Z_mean = mean(Z,1);
        
        A_mean = abs(Z_mean);
        deltaphi_mean = angle(Z_mean);
        deltaphi_mean = mod(deltaphi_mean,2*pi);
        
        %  amplitude = abs(Y1(fw_index,:));
        %  phase     = angle(DFF_fft(fw_index,:));
        %  realpart  = real(Y(ind_fstim,:));
        %  imaginary = imag(Y(ind_fstim,:));
        %  deltaphi  = (phase - phase_delay + pi);
        % -phase_delay = Shift positive of the fluorescence
        % +pi = because of the fourier transform is done against a cosinus
        
        amplitude = A_mean;
        phase = deltaphi_mean;
        deltaphi  = deltaphi_mean;
        realpart  = real(amplitude.*exp(j.*deltaphi));
        imaginary = imag(amplitude.*exp(j.*deltaphi));
        
        
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

%% close binary files and write info (.mat and .nhdr)
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