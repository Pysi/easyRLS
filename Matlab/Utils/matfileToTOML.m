function matfileToTOML(filename)
% compatibility function for metadata

data = load(filename);

struct_data.size.x = data.x;
struct_data.size.y = data.y;
struct_data.size.z = data.z;
struct_data.size.t = data.t;

struct_data.meta.layers = data.Z;
struct_data.meta.space = data.space;
struct_data.meta.bytedepth = data.pixtype;

basename = split(filename, '.mat');
assert(length(basename) == 2);
basename = basename{1};
new_filename = [basename '.toml'];

toml.write(new_filename, struct_data);

end