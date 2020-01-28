attribute vec4 vertex_position;
attribute vec2 texture_coord;
attribute vec4 vertex_colour;
attribute vec3 vertex_normal;

varying vec2 interpolated_texture_coord;
varying vec4 interpolated_vertex_colour;
varying vec3 interpolated_vertex_normal;

uniform mat4 mvp_matrix;

void main(void) {
	interpolated_texture_coord = texture_coord;
	interpolated_vertex_colour = vertex_colour;
	interpolated_vertex_normal = vertex_normal;
	
	gl_Position = mvp_matrix * vertex_position;
}
