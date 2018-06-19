function computePhaseMap(F, per, on)
%computePhaseMap is an alias function for phasemap per pixel / per neuron

    switch on
        case 'dff'
            switch per
                case 'neuron'
                    phaseMapNeuron(F);
                case 'pixel'
                    phaseMapPixel(F);
                otherwise
                    warning('phasemap not computed');
            end
        case 'signal'
            switch per
%                 case 'neuron'
%                     phaseMapNeuronSignal(F);
                case 'pixel'
                    phaseMapPixelSignal(F);
                otherwise
                    warning('phasemap not computed');
            end
        otherwise
            warning('phasemap not computed');
            
    end
    
end
