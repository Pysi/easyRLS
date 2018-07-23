
% get Focus
root = '/home/ljp/Science/Projects/RLS/';
%root = '/media/Coolcat/Science/Projects/RLS/'

study = '';
date = '2018-05-24';
run =7;

F = NT.Focus(root, study, date, run);

F.Analysis.StimulusFrequency = 0.2;       % frequency of stimulus (Hz) for phasemap computation


%% show phasemap
Focused.phaseMapViewer(F, 'dff pixel',10)
%% get grey stack image
mgray = Focused.Mmap(F, 'graystack');
img = NaN(mgray.x, mgray.y);

%% set parameters
tag = 'DFFPixel'
z = 20; 
t = 3000;



%% select layer to view    
z=20
inputInfo = fullfile(F.dir(tag), [num2str(z, '%02d') '.mat']);
m{z}.matfile = matfile(inputInfo); % readable matfile (prevents from loading all indices at the same time)
mmap = recreateMmap(F,m{z}.matfile.mmap); % recreates mmap, will be actualized when z changes

indices = m{z}.matfile.indices; % loads indices, will be actualized when z changes

img = NaN(mgray.x, mgray.y);

img(indices) = mmap.Data.bit(t,:);

figure;imshow(img)

%% Get indices of selected point and plot corresponding time trace
%figure;plot(indices)
% 366 486
% 171 86
% 71 542

% cursor_info(1).Position(1) = 366;
% cursor_info(1).Position(2) = 486;
% 
% cursor_info(2).Position(1) = 171;
% cursor_info(2).Position(2) = 86;
% 
% cursor_info(3).Position(1) = 71;
% cursor_info(3).Position(2) = 542;

%imfreehandd
i = 2
Iselected = sub2ind( size(img)  , cursor_info(i).Position(1) , 1018-cursor_info(i).Position(2)+1 );
Iselected_map =  find(indices==Iselected) ;


figure;plot( mmap.Data.bit(:,Iselected_map ))

%% Calculate fft of selected time trace
 % Define stimulation parameters
     fstim = F.Analysis.StimulusFrequency; % frequency of stimulus

    fstim = fstim;                              % Stimulation frequency
    N = F.param.NCycles ;                       % Number of images per layer
    fs = 1000 / (F.dt * F.param.NLayers);       % Frame rate at which images per layer are acquired
    dt = 1/fs;                                  % Sampling period
    T = N*dt;                                   % Total time of acquisition

    % Define frequency vector
    f = fs*[0:1:N/2]/N;

    % Finds the peak at the given frequency
    f_round = round(f,3);
    ind_fstim = find(f_round==fstim)

Y = fft(mmap.Data.bit(:, Iselected_map),[],1 );
            
figure;plot(abs(Y))
abs(Y(ind_fstim))


%%
% Y1 = get(gco,'yData');
% Y2 = get(gco,'yData');
figure;plot((Y1-mean(Y1))/std(Y1)); % noisy pixel
hold on;
plot((Y2-mean(Y2))/std(Y2)); % saturated noisy pixel
plot((Y3-mean(Y3))/std(Y3)); % motor neuron pixel

