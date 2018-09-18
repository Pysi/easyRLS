%% layers to analyse
Layers = F.Analysis.Layers;

% create dff directory
dffPath = F.dir('DFFPixel');
%Focused.mkdir(F, 'DFFPixel');

% load background and convert to uint16
load(F.tag('background'), 'background');

% sigstack (x,y,z,t) ((xy,z,t))
m = Focused.Mmap(F, 'corrected');

% get values
x = m.x; %#ok<*NASGU>
y = m.y;
z = 1; % only one layer concerned
t = m.t;
% Z = iz; % will be set at the end
T = m.T;
%% Average
for layer = [5:20]
    StackMean = zeros(m.x, m.y, 25, 'double');
    for time = 1:1000/25
        for i = 1:25
            StackMean(:,:,i) = StackMean(:,:,i) + double( m( :,:,layer,(25*(time-1)+i)) );
        end
    end
    StackMean = uint16( StackMean/(1000/25) );
    mkdir([root, 'Data/',F.date,'/', F.run, '/Analysis/MovieAverage/',num2str(layer), '/']);
    for i = 1:25
        imwrite(StackMean(:,:,i), [root, 'Data/',F.date,'/', F.run, '/Analysis/MovieAverage/',num2str(layer), '/image', num2str(i), '.tif']);
    end
end
%% Average Background substracted
for layer = [5:20]
    StackMean = zeros(m.x, m.y, 25, 'double');
    for time = 1:1000/25
        for i = 1:25
            StackMean(:,:,i) = StackMean(:,:,i) + double( m( :,:,layer,(25*(time-1)+i) ));
        end
    end
    StackMean = uint16(StackMean/(1000/25));
    mkdir([root, 'Data/',F.date,'/', F.run, '/Analysis/MovieAverage_BackGroupSub/',num2str(layer), '/']);
    for i = 1:25
        imwrite(StackMean(:,:,i)- uint16(mean(StackMean,3)), [root, 'Data/',F.date,'/', F.run, '/Analysis/MovieAverage_BackGroupSub/',num2str(layer), '/image', num2str(i), '.tif']);
    end
end