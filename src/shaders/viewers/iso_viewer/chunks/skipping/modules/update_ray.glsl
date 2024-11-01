
ray.start_distance = trace.distance;
ray.start_position = trace.position;
ray.span_distance = max(ray.end_distance - ray.start_distance, 0.0);
