function AnalysePhaseMap(F)

cd(F.dir('PhaseMapDFFPixel'))
% create output folder
mkdir( [F.dir('PhaseMapDFFPixel') '/rgb.stack' ])
    
% load amplitude and deltaph data stack
mAmplitude = Focused.Mmap(F, 'pmpdff_amplitude');
mDeltaPhi = Focused.Mmap(F, 'pmpdff_deltaphi');

m = mAmplitude; % neutral alias for position

amplitude = mAmplitude(:,:,m.Z,1);
deltaphi = mDeltaPhi(:,:,m.Z,1);


%%
figure

map = colormap(hsv);
ccode = round( mod(mod(deltaphi(:),2*pi),pi)/(pi)*32 )+1;
scatter(mod(mod(deltaphi(:),2*pi),pi),amplitude(:),10,map(ccode,:))
%%
figure

map = colormap(hsv);
ccode = round( mod(deltaphi(:),2*pi)/(2*pi)*63 )+1;
polarscatter(mod(deltaphi(:),2*pi),amplitude(:),10,map(ccode,:))

%%
amplitude = mAmplitude(:,:,m.Z,1);
deltaphi = mDeltaPhi(:,:,m.Z,1);

h=figure('visible','off')

map = colormap(hsv);
ccode = round( mod(deltaphi(:),2*pi)/(2*pi)*63 )+1;
polarscatter(mod(deltaphi(:),2*pi),amplitude(:),10,map(ccode,:))

clear amplitude deltaphi


saveas(h,[fullfile(F.dir('PhaseMapDFFPixel'), 'AmplitudeVsPhase.png')]) 

%%
    
% Plot Amplitude versus deltaphi
figure
colormap hsv
scatter(mod(deltaphi(:),2*pi),amplitude(:),10,mod(deltaphi(:),2*pi)/(2*pi))
xlabel('deltaphi')
ylabel('amplitude/noise')
title('2018-05-24 Run12 PhaseMap/dff/pixel')

M = [mod(deltaphi(:),2*pi) amplitude(:)];

k=8
idx = kmeans(M,k);


