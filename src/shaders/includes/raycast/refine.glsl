#include ../utils/sample_intensity.glsl;

/**
 * Refines the hit point by performing additional sampling steps.
 *
 * @param data: 3D texture sampler containing intensity data
 * @param end: End position of the previous raycasting step
 * @param step: Step vector for raycasting increments
 * @param threshold: Threshold value to determine if the ray has hit an object
 * @param refinements: Number of refinements for raycasting precision
 * @param position: Output vec3 where the refined position of the intersection will be stored
 * @param value: Output float where the refined value at the intersection will be stored
 */
void refine(in raycast_uniforms uniforms, in volume_uniforms u_volume, in vec3 ray_step, inout vec3 hit_position, out float hit_value)
{
    vec3 substep = ray_step / uniforms.refinements;  // Refined substep 
    hit_position -= ray_step;    // Step back to refine the hit point
    hit_value = 0.0;

    for (float i = 0.0; i < uniforms.refinements; i++) {

        hit_position += substep;  // Move position forward by substep                         
        hit_value = sample_intensity(u_volume.data, hit_position);  // Sample value again with refined position

        if (hit_value > uniforms.threshold) 
            return;   
    }
}