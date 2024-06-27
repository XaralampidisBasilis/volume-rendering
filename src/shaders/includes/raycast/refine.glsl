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
void refine_hit(in sampler3D data, in vec3 end, in vec3 step, in float threshold, in float refinements, out vec3 position, out float value)
{
    vec3 substep = step / refinements;  // Refined substep 
    position = end - step;    // Step back to refine the hit point
    value = 0.0;

    for (float i = 0.0; i < refinements; i++) {

        position += substep;  // Move position forward by substep                         
        value = texture(data, position).r;  // Sample value again with refined position

        if (value > threshold) 
            return;   
    }
}