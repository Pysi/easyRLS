% this scripts allows to build a single matrix mask with old style masks

% to get x and y
load('/home/ljp/Science/Hugo/easyRLS/Data/2018-03-27/Run 10/Files/rawRAS.mat')

cd '/home/ljp/Science/Hugo/easyRLS/Data/2018-03-27/Run 10/BACKUP_geoffrey-analysis/signal_stacks'

Layers = 3:20;

% inits the mask
mask = false(x,y,20);

for i = Layers
    load([num2str(i) '/contour.mat'], 'w');
    buff = false(x,y);
    buff(w) = true;
    buff = flip(buff, 1);
    mask(:,:,i) = buff;
end


cd '/home/ljp/Science/Hugo/easyRLS/Data/2018-03-27/Run 10/Files/IP'

save('mask.mat', 'mask');