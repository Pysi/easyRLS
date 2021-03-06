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
filename = fullfile( F.dir('Run'), 'Stimulus.txt') ;%'/home/ljp/Science/Projects/RLS/Data/2018-06-14/Run 19/Stimulus.txt';
delimiter = '\t';
formatSpec = '%*q%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);
Time = dataArray{:, 1};
Motor = dataArray{:, 2};
clearvars filename delimiter formatSpec fileID dataArray ans;



% Interpolate and plot stimulus data
% interpolate Stimulus signal at the image acquisition frequency (for example 50Hz)
Time = (Time - Time(1)) + 0.14;  % time in seconds   % the added constant is the time when the first motor position is recorded. The motor is acquired at 10Hz. The extra 40ms were added to best overlay the motor signal with a -cos function, which is our control signal
Tq = linspace(0.012,1199.988,60000); % 
Motor_inter  = interp1(Time,Motor,Tq,'spline');


Time = Tq;% clear Tq;

N = length(Motor_inter)
%%



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
            
% phase of stimulus   
% fw_index = 234:246; % frequency band of stimulus 

is = 2251;
ie = 3000;
Window = is:ie;

Window = [2061:2940];

Stim = Motor_inter(iz:20:end)';
Stim_fft = fft(Stim(Window));
realStim_fft = abs(Stim_fft);
[pks fw_index]=findpeaks(realStim_fft(1:end/2),'MinPeakHeight',2000);

%fw_index = find(realStim_fft(1:end/2) > 4000);
fw_index=fw_index';
phase_Stim_fw = angle(Stim_fft(fw_index));
N=length(Window);
f_window = fs*[0:1:N/2]/N;
f_Stim_tw = f_window(fw_index)';
disp(['Frequency = ', num2str(f_Stim_tw)]);

DFF_fft = fft(mdff.Data.bit(Window, i),[],1);
phase_DFF_fft_fw = angle(DFF_fft(fw_index,:)) ;

deltaphi_fw = phase_DFF_fft_fw - phase_Stim_fw ;

deltaphi_fw_cor = deltaphi_fw;%./(f_Stim_tw) * 0.2;   % (i) transform deltaphi for every frequency in a time delay and then (ii) calculate the phase shift that corresponds to this time delay at the wanted stimulus frequency of 0.2Hz 



            % Calculate response amplitde in units of signal-to-noise
      %      Y = fft(mdff.Data.bit(:, i),[],1);
            Y1 = abs(DFF_fft);
%             Y1m =mean(Y1([100:200 300:400 550:650],:),1);
%             Y1s = std(Y1([100:200 300:400 550:650],:),[],1);

             Y1m =mean(Y1([100:200 300:400 ],:),1);
             Y1s = std(Y1([100:200 300:400 ],:),[],1);
             
 window_noise = 80:120;
 %window_noise = [40:60 80:110];
               Y1m =mean(Y1(window_noise,:),1);
             Y1s = std(Y1(window_noise,:),[],1);

            %Y1 = (Y1-Y1m)./Y1s;
            Y1 = (Y1-Y1m)./Y1m;
            



Z = Y1(fw_index,:).*( cos(deltaphi_fw_cor)  + j *sin(deltaphi_fw_cor)   ) ;

Z_mean = mean(Z,1);

A_mean = abs(Z_mean);
deltaphi_mean = angle(Z_mean);

deltaphi_mean = mod(deltaphi_mean,2*pi);
            

            % extract peak from dff
            %amplitude = max(abs(Y));
            %amplitude = abs(Y1(fw_index,:));
            amplitude = A_mean;
            phase     = angle(DFF_fft(fw_index,:));
          %  realpart  = real(Y(ind_fstim,:));
          %  imaginary = imag(Y(ind_fstim,:));
            deltaphi  = (phase - phase_delay + pi);
             phase     = deltaphi;
            
deltaphi  = deltaphi_mean;



            
            realpart  = real(amplitude.*exp(j.*deltaphi));
            imaginary = imag(amplitude.*exp(j.*deltaphi));
            
                % -phase_delay = Shift positive of the fluorescence
                % +pi = because of the fourier transform is done against a cosinus

            % fills buffer
            for label = labels
                %label
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