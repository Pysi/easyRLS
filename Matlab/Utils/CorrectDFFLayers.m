
% get Focus
root = '/home/ljp/Science/Projects/RLS/';
study = '';
date = '2018-06-07';
run = 3;

F = NT.Focus(root, study, date, run);

%% get grey stack image
mgray = Focused.Mmap(F, 'graystack');
img = NaN(mgray.x, mgray.y);

%% set parameters
tag = 'DFFPixel'
z = 20; 
t = 3000;



%% select layer to view    
inputInfo = fullfile(F.dir(tag), [num2str(z, '%02d') '.mat']);
m{z}.matfile = matfile(inputInfo); % readable matfile (prevents from loading all indices at the same time)
mmap = recreateMmap(F,m{z}.matfile.mmap); % recreates mmap, will be actualized when z changes

indices = m{z}.matfile.indices; % loads indices, will be actualized when z changes

img = NaN(mgray.x, mgray.y);

img(indices) = mmap.Data.bit(t,:);

figure;imshow(img)


%%  
mmapIn = m{z}.matfile.mmap;

p = split(mmapIn.Filename, ['Analysis' filesep]); % gets the relative part of the path
relPath = p{end}; % takes the end
binFile = fullfile(F.dir('Analysis'), relPath);


mmap = memmapfile(...
                binFile,...
                'Format',mmapIn.Format,...
                'Writable',true...
                );


mmap.Data.bit(t,:) = mmap.Data.bit(t-1,:);


        
