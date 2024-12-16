
float debug_frag_shaded_luminance = dot(frag.shaded_color.rgb, vec3(0.2126, 0.7152, 0.0722));

debug.frag_shaded_luminance = vec4(vec3(debug_frag_shaded_luminance), 1.0);
