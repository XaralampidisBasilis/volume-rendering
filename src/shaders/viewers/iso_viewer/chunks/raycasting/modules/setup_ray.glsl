
/* Set ray origin and direction */

    ray.origin_position = v_camera;
    ray.step_direction = normalize(v_direction);

/* Compute global bound distances of ray with the volume box */

    // volume box 
    ray.box_min_position = vec3(0.0);
    ray.box_max_position = volume.size;

    // shrink volume box by a small amount to avoid numerical instabilities in the boundary
    ray.box_min_position += volume.spacing * MILLI_TOL;
    ray.box_max_position -= volume.spacing * MILLI_TOL;

    // compute rays bound distances with the volume box
    vec2 ray_box_bounds = box_bounds(ray.box_min_position, ray.box_max_position, ray.origin_position);
    ray_box_bounds = max(ray_box_bounds, 0.0);
    ray_box_bounds.x = min(ray_box_bounds.x, ray_box_bounds.y);
    ray.box_min_distance = ray_box_bounds.x;
    ray.box_max_distance = ray_box_bounds.y;

/* Compute intersection distances of ray with the volume box */ 

    // compute current ray intersection distances with the volume box
    vec2 ray_box_distances = intersect_box(ray.box_min_position, ray.box_max_position, ray.origin_position, ray.step_direction);
    ray_box_distances = max(ray_box_distances, 0.0);
    ray_box_distances.x = min(ray_box_distances.x, ray_box_distances.y);

    // update ray box distances
    ray.box_start_distance = ray_box_distances.x;
    ray.box_end_distance = ray_box_distances.y;
    ray.box_span_distance = ray.box_end_distance - ray.box_start_distance;
    ray.box_start_position = ray.origin_position + ray.step_direction * ray.box_start_distance;
    ray.box_end_position = ray.origin_position + ray.step_direction * ray.box_end_distance;

    // update ray distances
    ray.start_distance = ray.box_start_distance;
    ray.end_distance = ray.box_end_distance;
    ray.span_distance = ray.box_span_distance;
    ray.start_position = ray.box_start_position;
    ray.end_position = ray.box_end_position;

/* Update trace */

    trace_prev = trace;
    trace.distance = ray.start_distance;
    trace.position = ray.start_position;
    trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
    trace.voxel_texture_coords = trace.position * volume.inv_size;

