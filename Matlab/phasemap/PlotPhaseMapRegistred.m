function PlotPhaseMapRegistred(F,trans_mode, max)
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

outdir_rmcg = [F.get.regPath(F), '/', trans_mode, '_phasemap_ON_zBrain_Elavl3-H2BRFP_198layers_RGB_redmag-cyangreen'];
mkdir(outdir_rmcg);

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
v_max = max;
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
    value_yb(find(and(  ~and(deltaphi*2*pi > 5/4*pi ,deltaphi*2*pi < 3/2*pi) ,  ~and(deltaphi*2*pi > pi/4 ,deltaphi*2*pi < pi/2) ))) = 0;
    imhsv(:,:,3) =  value_yb;
    imwrite(hsv2rgb(imhsv),[outdir_yb filesep 'layer' num2str(l,'%02d') '.tif']);

% == red and cyan
    value_rc = value;
    value_rc(find(and(  ~and(deltaphi*2*pi > 0*pi ,deltaphi*2*pi < 1/4*pi) ,  ~and(deltaphi*2*pi > pi ,deltaphi*2*pi < 5/4*pi) ))) = 0;
    imhsv(:,:,3) =  value_rc;
    imwrite(hsv2rgb(imhsv),[outdir_rc filesep 'layer' num2str(l,'%02d') '.tif']);
    
% == magenta and green
    value_mg = value;
    value_mg(find(and(  ~and(deltaphi*2*pi > 3/2*pi ,deltaphi*2*pi < 7/4*pi) ,  ~and(deltaphi*2*pi > pi/2 ,deltaphi*2*pi < 3/4*pi) ))) = 0;
    imhsv(:,:,3) =  value_mg;    
    imwrite(hsv2rgb(imhsv),[outdir_mg filesep 'layer' num2str(l,'%02d') '.tif']);
    
% == redmag and cyangreen
    value_rmcg = value;
    value_rmcg(find(and(  ~and(deltaphi*2*pi > 3/4*pi ,deltaphi*2*pi < pi) ,  ~and(deltaphi*2*pi > 7/4*pi ,deltaphi*2*pi < 2*pi) ))) = 0;
    imhsv(:,:,3) =  value_rmcg;
    imwrite(hsv2rgb(imhsv),[outdir_rmcg filesep 'layer' num2str(l,'%02d') '.tif']);
end

end