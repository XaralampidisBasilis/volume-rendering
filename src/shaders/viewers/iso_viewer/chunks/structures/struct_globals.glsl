// struct to hold global parameters and settings for raymarching
#ifndef STRUCT_GLOBALS
#define STRUCT_GLOBALS

// struct to hold some global parameters
struct Globals
{
    vec3  camera_position;         // position of the camera in 3d model coordinates
    vec3  min_position;            // minimum bounds for the volume region in 3d model coordinates
    vec3  max_position;            // maximum bounds for the volume region in 3d model coordinates

    float min_start_distance;      // minimum allowed starting distance for each ray
    float max_end_distance;        // maximum allowed ending distance for each ray
    float max_span_distance;       // maximum allowed span distance for each ray

    float min_step_scaling;        // minimum scaling factor for step sizea
    float max_step_scaling;        // maximum scaling factor for step size

    int   max_step_count;          // maximum allowed steps in raymarching for each ray
    int   max_skip_count;          // maximum allowed skips in raymarching for each ray

    float min_sample_threshold;    // minimum sample threshold for early ray termination
    float min_gradient_threshold;  // minimum gradient threshold for edge detection
};

Globals Globals()
{
    Globals globals;
    globals.camera_position = vec3(0.0);
    globals.min_start_distance = 0.0;
    globals.max_end_distance = 0.0;
    globals.max_span_distance = 0.0;
    globals.min_step_scaling = 1.0;
    globals.max_step_scaling = 1.0;
    globals.min_position = vec3(0.0);
    globals.max_position = vec3(0.0);
    globals.max_step_count = 0;
    globals.max_skip_count = 0;
    globals.min_sample_threshold = 0.0;
    globals.min_gradient_threshold = 0.0;
    return globals;
}

#endif // STRUCT_GLOBAL