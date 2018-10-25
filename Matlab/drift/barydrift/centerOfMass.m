function [a,b] = centerOfMass(img, threshold)
tmp = thresh(img, threshold);
tmp = double(tmp);

[sa, sb] = size(tmp);

mass = sum(tmp(:));

[A,B] = meshgrid(1:sa, 1:sb);
A = A';
B = B';
imgA = tmp .* A;
imgB = tmp .* B;

a = sum(imgA(:))/mass;
b = sum(imgB(:))/mass;
end

function thresholded = thresh(img, threshold)
tmp = img;
tmp(tmp<threshold) = 0;
tmp = tmp - threshold;
thresholded = tmp;
end