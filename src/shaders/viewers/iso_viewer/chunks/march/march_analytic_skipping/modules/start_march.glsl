
// start sampling constants
const vec4 sample_distances = vec4(0.0, 1.0/3.0, 2.0/3.0, 1.0);
const mat4 sample_matrix = mat4(
     1.0, -5.5,   9.0,   -4.5,
     0.0,  9.0, -22.5,   13.5,
     0.0, -4.5, 18.0, -13.5,
    0.0, 1.0, -4.5,   4.5 
);

// start trace
trace.distance = ray.start_distance;
trace.position = camera.position + ray.step_direction * ray.start_distance;
prev_trace = trace;

