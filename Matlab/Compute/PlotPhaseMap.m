function PlotPhaseMap(F,max,SHOW,SHOWfit)

cd(F.dir('PhaseMapDFFPixel'))
% create output folder
mkdir( [F.dir('PhaseMapDFFPixel') '/rgb.stack' ])

maximum = max;

for z = F.Analysis.Layers;
    
    % load amplitude and deltaph data stack
    mAmplitude = Focused.Mmap(F, 'pmpdff_amplitude');
    mPhase = Focused.Mmap(F, 'pmpdff_deltaphi');

    m = mAmplitude; % neutral alias for position

% calculate probability distribution of amplitudes
    amplitude = mAmplitude(:,:,z,1);
    power = amplitude.^2/2;

    [N, edges]= histcounts(amplitude*1,5000);

    bins = edges(2:end);
    counts = N;
    
    if (SHOW)
        figure;plot(bins,counts)
    end
    A_pp = double(bins * 1);                        % DFF amplitude peak-to-peak
    Pdf = counts/(  sum(counts) * sum(mean(diff(A_pp)))   );    % Probability of occurence

if (SHOW)
    figure
    for i = 1%:4
        semilogy(A_pp,Pdf);hold on;
    end
    xlim([0 100])
    ylim([0 1])
end

% %%
% hold on
% fplot(@(x) 0.25*gampdf(x,2.8,3),[0 ,10])

% === Fit with gamma function
    ft = fittype( 'a*gampdf(x,b,c)', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Lower = [0 0 0];
    opts.Upper = [inf inf inf];
    opts.StartPoint = [0.25 2.8 3];

    xData = A_pp';
    yData = Pdf';
    
   % ex_ind = find(xData>40,1);
    ex_ind = length(xData);
   
    [fitresult, gof] = fit( xData(5:ex_ind), yData(5:ex_ind), ft, opts );
    fitresult_norm = fitresult;
    fitresult_norm.a = 1; 
    
% === calculate 95% confidence level for noise rejection
    cdf = fitresult.a*gamcdf(xData,fitresult.b,fitresult.c);
    cdf_n = cdf/cdf(end);
    ind = find(cdf_n > 0.95,1);
    conv95           = xData(ind);
   
    if (SHOW)
         figure;plot(xData,cdf)
    end
 % === plot fit result  
 if (SHOWfit)
    figure;
    h  = plot( fitresult, A_pp, Pdf ); hold on
    plot([conv95 conv95] , [0.0001 1],'-k','Linewidth',2)
    title(['95% noise level @ ' num2str(conv95) '%'])
 %   legend( h, [Exp(i).name], 'fit', 'Location', 'NorthEast' );
    set(gca, 'YScale', 'log')
    ylim([0.0001 1])
    xlim([0 100])
    % Label axes
    xlabel 'DFF Amplitude (peak-to-peak)'
    ylabel 'Pdf'
    grid on
   end
  
   %% Plot PhaseMap
   
    img = ones(m.x, m.y, 3);	% saturation init to 1
    img(:,:,1) = mod(mPhase(:,:,z,1),2*pi)./(2*pi); 		% hue
    img(:,:,3) = mAmplitude(:,:,z,1)./maximum; 	% value

   
       tmp = mAmplitude(:,:,z,1) ;
       tmp(find(tmp <conv95)) = 0;
       img(:,:,3) = tmp./maximum;

    img = hsv2rgb(img);
    img = rot90(img); % rotate image to display head up
    
if (SHOW)
    figure
    imshow(img);
    title([titleFig '   ' 'z=' num2str(z)]);
end
    %% save phase map
    cd([F.dir('PhaseMapDFFPixel') '/rgb.stack' ])
    % Save RGB images
    imwrite(img,[  'layer' num2str(z,'%02d') '.tif']);
end
end
