interp vec2 interp_texture_coord;
interp vec3 interp_vertex_normal;

inform tex2 inform_texture;

return sample(inform_texture, interp_texture_coord);
