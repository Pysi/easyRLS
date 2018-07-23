function PlotPhaseMapRegistred(F,trans_mode)
% average reformated phasemaps for the focus in flist
disp(trans_mode);
outdir = [F.get.regPath(F), '/', trans_mode, '_phasemap_ON_zBrain_Elavl3-H2BRFP_198layers_RGB'];
mkdir(outdir);

outdir_yb = [F.get.regPath(F), '/', trans_mode, '_phasemap_ON_zBrain_Elavl3-H2BRFP_198layers_RGB_yellow-blue'];
mkdir(outdir_yb);

outdir_mg = [F.get.regPath(F), '/', trans_mode, '_phasemap_ON_zBrain_Elavl3-H2BRFP_198layers_RGB_magenta-green'];
mkdir(outdir_mg);

outdir_rc = [F.get.regPath(F), '/', trans_mode, '_phasemap_ON_zBrain_Elavl3-H2BRFP_198layers_RGB_red-cyan'];
mkdir(outdir_rc);

% get path
regPath = [F.get.regPath(F), '/WARP_phasemap_ON_zBrain_Elavl3-H2BRFP_198layers/'];

% go to folder
cd(fullfile(regPath));

% load realpart and imaginary part
file = dir('realpart.nrrd');
Ia(:,:,:) = double(nrrdread(file.name));

file = dir('imaginary.nrrd');
Ib(:,:,:) = double(nrrdread(file.name));

% Save RGB images
v_max = 20;
clear imhsv
for l = 1:198
    deltaphi = mod(atan2(Ib(:,:,l),Ia(:,:,l)) , 2*pi) / (2*pi);
    imhsv(:,:,1) =   mod(atan2(Ib(:,:,l),Ia(:,:,l)) , 2*pi) / (2*pi);
    imhsv(:,:,2) =   Ia(:,:,l,1)*0+1;
    value = sqrt( Ia(:,:,l).^2 + Ib(:,:,l).^2 )/v_max;
    imhsv(:,:,3) =  value;
    imwrite(hsv2rgb(imhsv),[outdir filesep 'layer' num2str(l,'%02d') '.tif']);

% == yellow and blue
    value_yb = value;
    value_yb(find(and(  ~and(deltaphi*2*pi > 9/8*pi ,deltaphi*2*pi < 11/8*pi) ,  ~and(deltaphi*2*pi > pi/8 ,deltaphi*2*pi < 3/8*pi) ))) = 0;
    imhsv(:,:,3) =  value_yb;
    imwrite(hsv2rgb(imhsv),[outdir_yb filesep 'layer' num2str(l,'%02d') '.tif']);

% == red and cyan
    value_rc_tmp = value;
    value_rc_tmp(find(and(  ~and(deltaphi*2*pi > 7/8*pi ,deltaphi*2*pi < 9/8*pi) ,  ~and(deltaphi*2*pi > 15/8*pi ,deltaphi*2*pi < 16/8*pi) ))) = 0;
    value_rc = value;
    value_rc(find( ~and(deltaphi*2*pi > 0/8*pi ,deltaphi*2*pi < 1/8*pi))) = 0;
    value_rc = value_rc_tmp+value_rc;
    imhsv(:,:,3) =  value_rc;
    imwrite(hsv2rgb(imhsv),[outdir_rc filesep 'layer' num2str(l,'%02d') '.tif']);
    
% == magenta and green
    value_mg = value;
    value_mg(find(and(  ~and(deltaphi*2*pi > 5/8*pi ,deltaphi*2*pi < 7/8*pi) ,  ~and(deltaphi*2*pi > 13/8*pi ,deltaphi*2*pi < 15/8*pi) ))) = 0;
    imhsv(:,:,3) =  value_mg;    
    imwrite(hsv2rgb(imhsv),[outdir_mg filesep 'layer' num2str(l,'%02d') '.tif']);
end

end