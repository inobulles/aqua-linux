interp vec3 interp_normal;
inform tex2 interp_texture;

return sample(interp_texture, interp_normal.xy);
