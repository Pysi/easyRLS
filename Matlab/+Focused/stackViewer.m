function stackViewer(F, tag)
%Focused.stackViewer is the focused wrapper for stackViewer
% it creates the memory map and optionally loads the mask

    switch nargin
        case 1
            tag = 'source';
    end

    titleFig = F.name; % get title
    mask = []; % default mask

    switch tag
        case 'ROImask' % particular case to view mask contour
            load(F.tag('mask'), 'mask');
            m = adapted4DMatrix(F, 'source');
        otherwise % return the taf
            m = adapted4DMatrix(F, tag);
    end
        
    switch tag
        case 'refStack'
            minmax = [400 4000];
        case 'pmpsig_amplitude'
            minmax = [0 30];
        case 'pmpdff_amplitude'
            minmax = [0 80];
        otherwise
            minmax = [400 3000];
    end

    % call stackViewer
    stackViewer(m, titleFig, mask, minmax)

end