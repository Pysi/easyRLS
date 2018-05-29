function computePhaseMap(F, per)
%computePhaseMap is an alias function for phasemap per pixel / per neuron

switch per
    case 'neuron'
        phaseMapNeuron(F);
    case 'pixel'
        phaseMapPixel(F);
    otherwise
        warning('phasemap not computed');
end

end