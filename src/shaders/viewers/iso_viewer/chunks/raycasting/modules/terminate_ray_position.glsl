

// terminate ray distances
ray.start_distance = ray.box_end_distance;
ray.end_distance = ray.box_end_distance;
ray.span_distance = 0.0;

// terminate ray positions
ray.start_position = ray.box_end_position;
ray.end_position = ray.box_end_position;
