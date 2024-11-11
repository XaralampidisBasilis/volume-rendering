

// // terminate ray distances
// ray.start_distance = 0.0;
// ray.end_distance = 0.0;
// ray.span_distance = 0.0;

// // terminate ray positions
// ray.start_position = vec3(0.0);
// ray.end_position = vec3(0.0);
// ray.end_position = vec3(0.0);

// set ray parameters to zero
ray = set_ray();

// discard fragment
#if TRACE_DISCARDING_DISABLED == 0
discard;  
#endif