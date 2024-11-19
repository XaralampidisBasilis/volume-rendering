
#include './compute_hermite_interpolation"

// compute values at roots and select the max
#pragma unroll_loop_start
for (int n = 0; n < 2; n++)
{
    // update position
    trace_roots[n].distance = t_roots[n];
    trace_roots[n].position = ray.camera_position + ray.step_direction * trace_roots[n].distance;
    trace_roots[n].voxel_coords = ivec3(trace_roots[n].position * u_volume.inv_spacing);
    trace_roots[n].voxel_texture_coords = trace_roots[n].position * u_volume.inv_size;

    // update sample
    trace_roots[n].sample_data = texture(u_textures.volume, trace_roots[n].voxel_texture_coords);
    trace_roots[n].sample_value = trace_roots[n].sample_data.r;

    // update max trace
    if (trace_roots[n].sample_value > max_trace.sample_value) 
    {
        max_trace = trace_roots[n];
    }
}
#pragma unroll_loop_end

// update interval for next iteration
#include "./compute_max_trace_gradient"
