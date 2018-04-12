% the function Tif to RAS is done to take ito account the frame order and the orientation

% this script just reads Tif images and writes it to a binary file

cd '/home/ljp/Science/Hugo/easyRLS/Data/2018-03-27/Run 10/BACKUP_geoffrey-analysis/ref_stack'
tmp = dir('*.tif');

out = 'refStack.bin';
outInfo = 'refStack.mat';
fid = fopen(out, 'wb');

for i = 1:length(tmp)
    img = imread(tmp(i).name);
    img = flip(img, 1);
    fwrite(fid, img, 'uint16');
end

fclose(fid);

% save info
load('/home/ljp/Science/Hugo/easyRLS/Data/2018-03-27/Run 10/Files/rawRAS.mat',  'x', 'y', 'z', 't', 'Z', 'T', 'space');
t = 1;
T = 1;
save(outInfo, 'x', 'y', 'z', 't', 'Z', 'T', 'space');

