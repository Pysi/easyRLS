function printPhaseMap(outputDir, mAmplitude, mPhase, titleFig, minmax)
% prints in png

m = mAmplitude; % neutral alias for position
min = minmax(1);
max = minmax(2);

for iz = mAmplitude.Z
    img = ones(m.x, m.y, 3);	% inits saturation to 1
    img(:,:,1) = mod(mPhase(:,:,iz,1),2*pi)./(2*pi); 		% hue
    img(:,:,3) = ( mAmplitude(:,:,iz,1) - min) / max; 	% value
    img = hsv2rgb(img);
    img = rot90(img); % rotate image to display head up
    imwrite(img, fullfile(outputDir, [num2str(iz,'%02d') '.png']));
end

end