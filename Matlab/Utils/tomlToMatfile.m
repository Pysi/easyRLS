function tomlToMatfile(filename)
% compatibility function for metadata

info = toml.read(filename);

x = info.size.x;
y = info.size.y;
z = info.size.z;
t = info.size.t;

Z = info.meta.layers;
T = 1:info.size.t;
pixtype = info.meta.bytedepth;
space = info.meta.space;

basename = split(filename, '.toml');
assert(length(basename) == 2);
basename = basename{1};
new_filename = [basename '.mat'];

save(new_filename, 'x', 'y', 'z', 't', 'Z', 'T', 'space', 'pixtype');

end