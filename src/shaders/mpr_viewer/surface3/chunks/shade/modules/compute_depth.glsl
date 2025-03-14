
// Compute frag depth in screen space
// https://carmencincotti.com/2022-05-02/homogeneous-coordinates-clip-space-ndc/

vec4 model_position = vec4(trace.position * u_volume.spacing, 1.0); 
vec4 clip_position = v_clip_space_matrix * model_position; 
frag.position = clip_position.xyz / clip_position.w; 
frag.position = frag.position * 0.5 + 0.5;  
frag.depth = frag.position.z;  

    