
/* Compute intersection distances of ray with the volume bounding box */ 

    // get volume bounding box in model space
    vec3 bbox_min_position = volume.min_position;
    vec3 bbox_max_position = volume.max_position;

    // elarge volume bounding box by a voxel to include linear filtering values
    bbox_min_position -= volume.spacing;
    bbox_max_position += volume.spacing;

    // make sure volume bounding box is not bigger than volume box
    bbox_min_position = max(bbox_min_position, ray.box_min_position);
    bbox_max_position = min(bbox_max_position, ray.box_max_position);

    // compute ray intersection distances with the volume bounding box
    vec2 ray_bbox_distances = intersect_box(bbox_min_position, bbox_max_position, ray.origin_position, ray.step_direction);
    ray_bbox_distances = max(ray_bbox_distances, 0.0);

/* Update ray and traces based on the volume bounding box*/

    bool intersected_bbox = ray_bbox_distances.x < ray_bbox_distances.y;

    // if there is intersection with bounding box update ray start and trace position
    if (intersected_bbox)
    {
        // update ray bounds with bounding box
        ray.start_distance = ray_bbox_distances.x;
        ray.end_distance   = ray_bbox_distances.y;
        ray.span_distance  = ray.end_distance - ray.start_distance;
        ray.start_position = ray.origin_position + ray.step_direction * ray.start_distance;
        ray.end_position   = ray.origin_position + ray.step_direction * ray.end_distance;

        // update trace based on ray start
        trace_prev = trace;
        trace.distance = ray.start_distance;
        trace.position = ray.start_position;
        trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
        trace.voxel_texture_coords = trace.position * volume.inv_size;

        // compute skipped distance
        trace.spanned_distance = ray.start_distance - ray.box_start_distance;
        trace.skipped_distance = ray.start_distance - ray.box_start_distance;
    }

    // if there isn't intersection with the volume bounding box end ray and trace positions
    else
    {
        #include "./modules/terminate_ray"
    }

