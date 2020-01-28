attrib vec4 vertex_position;
attrib vec2 texcoord;
attrib vec4 colour;
attrib vec3 vertex_normal;

interp vec3 interp_normal;
inform mat4 mvp_matrix;

interp_normal = vertex_normal;
return mvp_matrix * vertex_position;
