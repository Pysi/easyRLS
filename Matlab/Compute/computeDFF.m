function computeDFF(F, per)
%computeDFF is an alias function for dff per pixel / per neuron

switch per
    case 'neuron'
        dffNeuron(F);
    case 'pixel'
        dffPixel(F);
    otherwise
        warning('dff not computed');
end

end