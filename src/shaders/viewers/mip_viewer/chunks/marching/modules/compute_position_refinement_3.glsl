
// update trace
trace = max_trace;

// refine max trace gradient
#include './compute_trace_gradient"
max_trace = trace;

// update trace based on gradient direction
trace.distance += ray.step_distance * sign(max_trace.derivative);
trace.distance = clamp(trace.distance, ray.box_start_distance, ray.box_end_distance);
trace.position = ray.camera_position + ray.step_direction * trace.distance;
trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
trace.voxel_texture_coords = trace.position * u_volume.inv_size;
trace.sample_data = texture(u_textures.volume, trace.voxel_texture_coords);
trace.sample_value = trace.sample_data.r;
#include './compute_trace_gradient"

// select intervals based on gradient direction
bool select  = max_trace.derivative > 0.0;
vec2 s = vec2(0.0, 1.0);
vec2 t = select ? vec2(max_trace.distance, trace.distance) : vec2(trace.distance, max_trace.distance);
vec2 f = select ? vec2(max_trace.sample_value, trace.sample_value) : vec2(trace.sample_value, max_trace.sample_value);
vec2 d = select ? vec2(max_trace.derivative, trace.derivative) : vec2(trace.derivative, max_trace.derivative);
d *= t.y - t.x;

// compute cubic hermite coefficients
vec4 coeff = hermite_cubic_coefficients(s, f, d);

// compute derivative hermite coefficients
coeff *= vec4(0.0, 1.0, 2.0, 3.0);

// compute the roots of the equation H(t)' = 0
vec2 s_roots = quadratic_roots(coeff.yzw);

// clamp normalized rooths to the interval
s_roots = clamp(s_roots, s.xx, s.yy);

// denormalize roots
vec2 t_roots = mix(t.xx, t.yy, s_roots);

// compute values at roots and select the max
for (int i = 0; i < 2; i++)
{
    // update position
    trace.distance = t_roots[i];
    trace.position = ray.camera_position + ray.step_direction * trace.distance;
    trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
    trace.voxel_texture_coords = trace.position * u_volume.inv_size;

    // update sample
    trace.sample_data = texture(u_textures.volume, trace.voxel_texture_coords);
    trace.sample_value = trace.sample_data.r;

    // update gradients
    #include './compute_trace_gradient"

    // update max trace
    if (max_trace.sample_value < trace.sample_value) max_trace = trace;
}
