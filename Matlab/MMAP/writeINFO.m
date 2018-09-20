function writeINFO(path, x, y, z, t, Z, T, space, pixtype)
%writeINFO writes the matfile which comes along the bin file

save(path, 'x', 'y', 'z', 't', 'Z', 'T', 'space', 'pixtype');

end