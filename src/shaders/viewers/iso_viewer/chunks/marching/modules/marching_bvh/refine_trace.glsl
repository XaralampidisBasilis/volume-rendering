
// reverse trace to the start of the block and a bit before
float backstep = u_volume.spacing_length * 2.0;

// take a backstep 
trace.distance -= backstep;
trace.distance = max(trace.distance, ray.box_start_distance);
trace.position = ray.origin_position + ray.step_direction * trace.distance;
trace.voxel_coords = ivec3(floor(trace.position * u_volume.inv_spacing));
trace.voxel_texture_coords = trace.position * u_volume.inv_size;

// update parameters
trace.spanned_distance -= backstep;
trace.skipped_distance -= backstep;
trace.stepped_distance -= backstep;

// sample trace
#include "../sample_trace"

// prepare for next step
#include "../prepare_trace" 
