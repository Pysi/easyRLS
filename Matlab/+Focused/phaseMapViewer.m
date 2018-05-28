function phaseMapViewer(F, np)
%+Focused version of phaseMapViewer

switch np
    case 'neuron'
        phaseMapViewer(Focused.Mmap(F, 'pmn_amplitude'),Focused.Mmap(F, 'pmn_deltaphi'), [F.name ' phaseMap'], 100);
    case 'pixel'
        phaseMapViewer(Focused.Mmap(F, 'pmp_amplitude'),Focused.Mmap(F, 'pmp_deltaphi'), [F.name ' phaseMap'], 100);
end

end 
