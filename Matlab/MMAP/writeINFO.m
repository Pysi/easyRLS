function writeINFO(path, x, y, z, t, layers, space, pixtype)
%writeINFO writes the toml file which comes along the binary file

info.size.x = x;
info.size.y = y;
info.size.z = z;
info.size.t = t;

info.meta.layers = layers;
info.meta.space = space;
info.meta.bytedepth = pixtype;

toml.write(path, info);

end