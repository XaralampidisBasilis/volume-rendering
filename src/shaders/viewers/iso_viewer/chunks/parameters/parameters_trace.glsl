#ifndef PARAMETERS_TRACE
#define PARAMETERS_TRACE

// Struct to hold information about a ray trace intersection in normalized coordinates
struct parameters_trace 
{
    vec3  position;   // position in model space
    vec3  texel;      // normalized texture coordinates
    vec3  coords;   
    vec3  normal;     // normal in model space
    vec3  gradient;   // gradient in model space
    vec3  color;
    vec3  shading;
    float value;     // Scalar value at the intersection
    float error;
    float distance;  // Distance the ray has traveled to the intersection
    float depth;  
    float dithering;
    float skipped;  
    float stepping;  
    float spacing;
    float gradient_norm;
    float derivative;
    float derivative2;
    float derivative3;
    int   steps;
};

void set_trace(out parameters_trace trace)
{
    trace.position      = vec3(0.0);
    trace.texel         = vec3(0.0);
    trace.coords        = vec3(0.0);
    trace.normal        = vec3(0.0);
    trace.gradient      = vec3(0.0);
    trace.color         = vec3(0.0);
    trace.shading       = vec3(0.0);
    trace.value         = 0.0;
    trace.error         = 0.0;
    trace.distance      = 0.0;
    trace.depth         = 0.0;
    trace.dithering     = 0.0;
    trace.skipped       = 0.0;
    trace.stepping      = 0.0;
    trace.spacing       = 0.0;
    trace.gradient_norm = 0.0;
    trace.derivative    = 0.0;
    trace.derivative2   = 0.0;
    trace.derivative3   = 0.0;
    trace.steps         = 0;
}

#endif
