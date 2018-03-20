% put sth in img


figure; imshow(equalize_histogram(img))

% Auto brain countour
bg_img = mean2(img);
H = fspecial('disk',20);
tmp1 = imfilter(img,H,'replicate');
tmp2 = img*0;
tmp2(tmp1>bg_img*(1-(0.005*12))) = 1;
tmp2 = bwareaopen(tmp2,(size(img,1)*size(img,2))/4);

hold on;
contour(tmp2)

% here we have the contour


[B, ~] = bwboundaries(tmp2,'noholes');
% [x, y] = reducem(B{1}(:,1), B{1}(:,2), 10); % reducem ??
% boundary = [y, x];
boundary = B{1};
boundary = boundary(1:100:end, :);
for k = 1:length(B)
    plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2)
end
poly = impoly(gca, [boundary(:,2) boundary(:,1)]);


boundary_2 = poly.wait;
BW = poly2mask(boundary_2(:,1), boundary_2(:,2), size(tmp2,1), size(tmp2,2));
% w = find(BW==1);

contour(BW)

%%
        
       
        
        % Manual brain countour
%         if binsize == 10
%             BW = ones(size(Img1sm,1),size(Img1sm,2),'logical');
%             w = find(BW==1);
%         else
%             BW = roipoly;
%             w = find(BW==1);
%         end

        % --- Out directorties ---
        outdir = [F.Files 'signal_stacks/' num2str(layer) '/'];
        [status, message, messageid] = rmdir(outdir,'s');
        mkdir(outdir)
        save([F.Files 'signal_stacks/' num2str(layer) '/' 'contour.mat'], 'w');
    
    W{layer-(Layers(1)-1)} = w;