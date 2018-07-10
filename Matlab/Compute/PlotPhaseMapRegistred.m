function PlotPhaseMapRegistred(F,trans_mode)
% average reformated phasemaps for the focus in flist
disp(trans_mode);
outdir = [F.get.regPath(F), '/', trans_mode, '_phasemap_ON_zBrain_Elavl3-H2BRFP_198layers_RGB'];
mkdir(outdir);

% get path
regPath = [F.get.regPath(F), '/WARP_phasemap_ON_zBrain_Elavl3-H2BRFP_198layers/'];

% go to folder
cd(fullfile(regPath));

% load realpart an imaginary part
file = dir('realpart.nrrd');
Ia(:,:,:) = double(nrrdread(file.name));

file = dir('imaginary.nrrd');
Ib(:,:,:) = double(nrrdread(file.name));

% Save RGB images
v_max = 20;
clear imhsv
for l = 1:198
    imhsv(:,:,1) =   mod(atan2(Ib(:,:,l),Ia(:,:,l)) , 2*pi) / (2*pi);
    imhsv(:,:,2) =   Ia(:,:,l,1)*0+1;
    imhsv(:,:,3) =   sqrt( Ia(:,:,l).^2 + Ib(:,:,l).^2 )/v_max;
    imwrite(hsv2rgb(imhsv),[outdir filesep 'layer' num2str(l,'%02d') '.tif']);
end

end