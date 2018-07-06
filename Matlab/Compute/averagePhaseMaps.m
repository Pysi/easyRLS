function averagePhaseMaps(Flist)
% average reformated phasemaps for the focus in flist

manip = Flist; % this is a list of focus
F = manip{1}; % sample focus
outdir = fullfile(F.dir('AveragedPhaseMaps'), 'stack');
mkdir(outdir);
runs = fopen(fullfile(outdir, 'runs'), 'w');

F = manip{1};
% get path
regPath = F.get.regPath(F);
[~, refo] = F.get.autoTransName(F, 'warp', 'phasemap');

cd(fullfile(regPath, refo)); % go to folder

file = dir('realpart.nrrd');
Ia(:,:,:,1) = double(nrrdread(file.name))*0;
Ib(:,:,:,1) = double(nrrdread(file.name))*0;

% load realpart an imaginary part
for k = (1:size(manip, 2))
    F = manip{k}; % current focus
    disp(F.name);
    fprintf(runs, '%s\n', F.name);
    
    % get path
    regPath = F.get.regPath(F);
    [~, refo] = F.get.autoTransName(F, 'warp', 'phasemap');
    
    cd(fullfile(regPath, refo)); % go to folder
    
    file = dir('realpart.nrrd');
    Ia(:,:,:,1) = Ia(:,:,:,1) + double(nrrdread(file.name));
    
    file = dir('imaginary.nrrd');
    Ib(:,:,:,1) = Ib(:,:,:,1) + double(nrrdread(file.name));
    
    % Save phase registered phase map
   % clear i
   % Z(:,:,:,k) = Ia(:,:,:,k) + 1i * Ib(:,:,:,k);
    
%     v_max = 0.3;
%     clear imhsv
%     for l = 1:size(Z(:,:,:,k),3)
%         imhsv(:,:,1) =   mod(atan2(Ib(:,:,l,k),Ia(:,:,l,k)) , 2*pi) / (2*pi);
%         imhsv(:,:,2) =   Ia(:,:,l,1)*0+1;
%         imhsv(:,:,3) =   sqrt( Ia(:,:,l,k).^2 + Ib(:,:,l,k).^2 )/v_max;
%         outdir = [F.Files 'Phase_map/PhaseMap_RGB_' RefBrain];
%         [status,message,messageid] = mkdir(outdir);
%     end
end

% Calculate mean
clear i
Ia_mean = Ia/size(manip, 2);
Ib_mean = Ib/size(manip, 2);
% Ia_mean = mean(Ia,4);
% Ib_mean = mean(Ib,4);

% Save RGB images
v_max = 20;
clear imhsv
for l = 1:178
    imhsv(:,:,1) =   mod(atan2(Ib_mean(:,:,l),Ia_mean(:,:,l)) , 2*pi) / (2*pi);
    imhsv(:,:,2) =   Ia_mean(:,:,l,1)*0+1;
    imhsv(:,:,3) =   sqrt( Ia_mean(:,:,l).^2 + Ib_mean(:,:,l).^2 )/v_max;
    imwrite(hsv2rgb(imhsv),[outdir filesep 'layer' num2str(l,'%02d') '.tif']);
end

fclose(runs);

end