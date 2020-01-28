interp vec2 interp_vertex_position;

inform tex2 inform_draw_texture;
inform tex2 inform_bloom_texture;

vec2 coords = interp_vertex_position / 2 + 0.5;
return sample(inform_draw_texture, coords) + sample(inform_bloom_texture, coords);
