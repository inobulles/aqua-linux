attrib vec4 attrib_vertex_position;
interp vec2 interp_vertex_position;

interp_vertex_position = attrib_vertex_position.xz;
return attrib_vertex_position.xzyw;
