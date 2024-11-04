
// STEPPING_NORMAL
/**
 * Adjusts the trace's stepping size based on the alignment between the normal and ray direction.
 * The dot product between the negative normal and the ray direction is used to determine the alignment, 
 * and the stepping size is adjusted accordingly.
 *
 * @input trace.normal             : the current surface normal at the trace position (vec3)
 * @input ray.step_direction            : the normalized direction vector of the ray (float)
 * @input ray.min_step_scaling   : the minimum stepping size for raymarching (float)
 * @input ray.max_step_scaling   : the maximum stepping size for raymarching (float)
 *
 * @output trace.step_scaling          : the adjusted ray stepping size (float)
 */

// calculate the alignment between the normal and the ray direction.
float normal_alignment = max(dot(-trace.normal, ray.step_direction), 0.0);

// interpolate between max_stepping and min_stepping based on the normal's alignment.
trace.step_scaling = mix(ray.max_step_scaling, ray.min_step_scaling, normal_alignment);
