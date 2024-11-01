
vec3 volume_min_position = volume.min_position;
vec3 volume_max_position = volume.max_position;

// make volume bounding box a voxel bigger to account for linear filtering
volume_min_position -= volume.spacing;
volume_max_position += volume.spacing;

// make sure volume bounding box is not bigger than ray bounding box
volume_min_position = max(volume_min_position, ray.box_min_position);
volume_max_position = min(volume_max_position, ray.box_max_position);

// save ray start distance for later computations
float ray_start_distance = ray.start_distance;

// compute ray intersection distances with the volume bounding box
vec2 ray_bbox_distances = intersect_box(volume_min_position, volume_max_position, ray.origin_position, ray.step_direction);
ray_bbox_distances = max(ray_bbox_distances, 0.0);
bool intersected_bbox = ray_bbox_distances.x < ray_bbox_distances.y;

// if there is intersection with bbox update ray and trace
if (intersected_bbox)
{
    // compute start end positions
    ray.start_distance = ray_bbox_distances.x;
    ray.end_distance = ray_bbox_distances.y;
    ray.span_distance = ray.end_distance - ray.start_distance;
    ray.start_position = ray.origin_position + ray.step_direction * ray.start_distance;
    ray.end_position = ray.origin_position + ray.step_direction * ray.end_distance;

    // update trace 
    trace_prev = trace;
    trace.distance = ray.start_distance;
    trace.position = ray.start_position;
    trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
    trace.voxel_texture_coords = trace.position * volume.inv_size;

    // compute skipped distance
    trace.skip_distance = max(ray.start_distance - ray_start_distance, 0.0);
    trace.skipped_distance += trace.skip_distance;
}
else
{
    // compute start end positions
    ray.start_distance = ray.box_end_distance;
    ray.start_position = ray.origin_position + ray.step_direction * ray.start_distance;
    ray.span_distance = 0.0;

    // update trace 
    trace_prev = trace;
    trace.distance = ray.start_distance;
    trace.position = ray.start_position;
    trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
    trace.voxel_texture_coords = trace.position * volume.inv_size;

    // compute skipped distance
    trace.spanned_distance = ray.max_span_distance;
    trace.skipped_distance = ray.max_span_distance;
}

