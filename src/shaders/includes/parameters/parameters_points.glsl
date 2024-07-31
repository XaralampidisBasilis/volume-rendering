#ifndef PARAMETERS_POINTS
#define PARAMETERS_POINTS

// Struct to hold information about the trace in model coordinates
struct parameters_points
{
    vec3 position[2]; 
    vec3 gradient[2]; 
    float value[2];   
};

parameters_points points;

void set_points()
{
    points.position = vec3[2](vec3(0.0), vec3(0.0));
    points.gradient = vec3[2](vec3(0.0), vec3(0.0));
    points.value = float[2](0.0, 0.0);    
}

void update_points
(
    in uniforms_volume u_volume,
    in parameters_trace trace
)
{
    // Save trace points in model coordinates
    points.value   [1] = points.value[0];
    points.position[1] = points.position[0];
    points.gradient[1] = points.gradient[0];

    points.value   [0] = trace.value;
    points.position[0] = trace.position * u_volume.size;
    points.gradient[0] = trace.gradient / u_volume.spacing;
}

#endif // PARAMETERS_POINTS
