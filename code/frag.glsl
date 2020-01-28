varying vec2 interpolated_texture_coord;
varying vec4 interpolated_vertex_colour;
varying vec3 interpolated_vertex_normal;

uniform sampler2D texture_sampler;

void main(void) {
	gl_FragColor = texture2D(texture_sampler, interpolated_texture_coord);
}
