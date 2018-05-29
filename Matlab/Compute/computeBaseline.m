function computeBaseline(F, per)
%computeBaseline is an alias for per neuron or per pixel functions
    
    switch per
        case 'neuron'
            computeBaselineNeuron(F);
        case 'pixel'
            computeBaselinePixel(F);
        otherwise
            warning('baseline not computed');
    end

end