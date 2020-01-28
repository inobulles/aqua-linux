// list all the interpolated values passed on from the vertex shader

interp vec2 interp_texture_coord;
interp vec3 interp_vertex_normal;

// list all the information variables passed on from the application

inform tex2 inform_texture;

// sample the texture at the texture coordinate, and return that from the fragment shader

return vec4(interp_vertex_normal.xyz, 1.0);//sample(inform_texture, interp_texture_coord);// * interp_vertex_colour;
