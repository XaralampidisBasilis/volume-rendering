// Transform the fragment position to clip space
vec4 clip_position = v_projection_model_view_matrix * vec4(trace.position, 1.0); 

// Perform perspective division to get NDC space
vec3 ndc_position = clip_position.xyz / clip_position.w; 
    
// Calculate the depth value in the range [0, 1]
float ndc_depth = (ndc_position.z + 1.0) * 0.5;  

// cap frag depth when near fragment
gl_FragDepth = max(ndc_depth, 0.001);

    