
// Compute trace position in clip space
vec4 clip_position = v_projection_model_view_matrix * vec4(trace.position, 1.0); 

// Compute frag position in NDC space
frag.position = clip_position.xyz / clip_position.w; 
frag.position = frag.position* 0.5 + 0.5;  
frag.depth = frag.position.z;  

// Set frag depth
gl_FragDepth = frag.depth;

    