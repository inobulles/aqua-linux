attrib vec4 attrib_vertex_position;
attrib vec2 attrib_texture_coord;
attrib vec3 attrib_vertex_normal;

interp vec2 interp_texture_coord;
interp vec3 interp_vertex_normal;

inform mat4 inform_mvp_matrix;

interp_texture_coord = attrib_texture_coord;
interp_vertex_normal = attrib_vertex_normal;

return inform_mvp_matrix * attrib_vertex_position;
