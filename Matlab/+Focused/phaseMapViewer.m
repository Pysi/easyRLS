function phaseMapViewer(F)
%+Focused version of phaseMapViewer

	phaseMapViewer(Focused.Mmap(F, 'amplitude'),Focused.Mmap(F, 'deltaphi'), [F.name ' phaseMap'], 100);


end 
