// terminate ray
ray.start_distance = ray.box_end_distance;
ray.start_position = ray.box_end_position;
ray.span_distance = 0.0;

// terminate trace
trace.distance = ray.box_end_distance;
trace.position = ray.box_end_position;
trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
trace.voxel_texture_coords = trace.position * volume.inv_size;

// terminate accumulated distances
trace.stepped_distance = 0.0;
trace.spanned_distance = ray.box_span_distance;
trace.skipped_distance = ray.box_span_distance;