%% get memory maps

mc = adapted4DMatrix(F, 'corrected');
md = adapted4DMatrix(F, 'DFFPixel');

%% loop to plot

for z = 3:8 

outputDirectory = F.dir('Run');
filename = [num2str(z, '%02d') '.avi'];
vw = VideoWriter(fullfile(outputDirectory, filename), 'Motion JPEG AVI');
vw.Quality = 92;

for t = 1:500
    % get base image
    img = mc(:,:,z,t); % imshow(img, [400 490]);
    img = double(img);

    % get dff details
    indices = md.indices{z};
    dff = md.mmaps{z}.Data.bit(t, :);
    dff = double(dff);

    % fills buffer with dff
    buffer = zeros(size(img));
    buffer(indices) = dff;
    % imshow(buffer, [0 10]);

    % threshold on dff
    thresh = 1.2;
    buffer(buffer<thresh) = 0;

    % add dff on green channel
    imgPlusDff = img;
    imgPlusDff(buffer>0) = imgPlusDff(buffer>0) + buffer(buffer>0); 

    % let 'place' for dff on image
    imgNoDff = img;
    imgNoDff(buffer>0) = 0;
    imageRGB = cat(3, imgNoDff, imgPlusDff, imgNoDff); %grayscale to RGB

    min = 400; max = 490;
    frame = (imageRGB - min)./ (max - min);
    frame(frame>1) = 1;
    frame(frame<0) = 0;
    if t == 1
        figure; h = imshow(frame);
        open(vw);
    else
        h.CData = frame;
    end
    writeVideo(vw,frame);
    pause(0.01)
end

close(vw);

end

%% bash to convert in webm after

% for i in 2 3 4 5 6 7 8;
% do ffmpeg -i "0$i.avi" -b:v 8M -bufsize 8M "0${i}.webm";
% done





