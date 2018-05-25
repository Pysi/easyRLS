function indices = maskToIndex(F, z)
%maskToIndex(F, Layer) returns the 1D indices for xy present in the mask for one layer
% F is the focus which gives the path of mask.mat
% z is the layer you want to retrive the index from

    load(F.tag('mask'), 'mask');

    indices = uint32(find(mask(:,:,z))); %#ok<IDISVAR,NODEF>

end
