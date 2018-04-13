function writeINFO(path, x, y, z, t, Z, T, space)
%printINFO prints the matfile which comes along the bin file

save(path, 'x', 'y', 'z', 't', 'Z', 'T', 'space');

end