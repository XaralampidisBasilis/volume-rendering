/**
 * Computes the intersection bounds of a ray with an axis-aligned bounding box.
 *
 * @param u_volume: struct containing volume-related uniforms.
 * @param frag_position: vec3 where the position of fragment is stored. The fragment is inside model's normalized coordinates
 * @param v_projection_model_view_matrix: a varying from the vertex shader that computes the mapping from model to clip space
 */
float compute_frag_depth
(
    in vec3 volume_size, 
    in vec3 ray_position
)
{
    // Transform the fragment position to clip space
    vec4 clip_position = v_projection_model_view_matrix * vec4(ray_position * volume_size, 1.0); 
    
    // Perform perspective division to get NDC space
    vec3 ndc_position = clip_position.xyz / clip_position.w; 
       
    // Calculate the depth value in the range [0, 1]
    float ndc_depth = (ndc_position.z + 1.0) * 0.5;  

    // cap frag depth when near fragment
    ndc_depth = max(ndc_depth, 0.001);

    return ndc_depth;
}

       