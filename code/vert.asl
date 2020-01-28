// list what each attribute is (in order)

attrib vec4 attrib_vertex_position;
attrib vec2 attrib_texture_coord;
attrib vec3 attrib_vertex_normal;

// list all the interpolated values to be passed onto the fragment shader

interp vec2 interp_texture_coord;
interp vec3 interp_vertex_normal;

// list all the information variables passed on from the application

inform mat4 inform_mvp_matrix;

// set variables to be interpolated to the vertex' attribute

interp_texture_coord = attrib_texture_coord;
interp_vertex_normal = attrib_vertex_normal;

// transform the vertex based on the mvp matrix, and return that from the vertex shader

return inform_mvp_matrix * attrib_vertex_position;
