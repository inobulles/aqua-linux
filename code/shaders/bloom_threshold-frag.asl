interp vec2 interp_vertex_position;
inform tex2 inform_texture;

vec4 colour = sample(inform_texture, interp_vertex_position / 2 + 0.5);
flt brightness = colour.r * 0.2126 + colour.g * 0.7152 + colour.b * 0.0722;

if (brightness > 0.7) return colour * brightness;
return vec4(vec3(0.0), 1.0);
