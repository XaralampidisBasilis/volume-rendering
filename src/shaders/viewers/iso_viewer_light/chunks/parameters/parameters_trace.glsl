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

void copy_trace(out parameters_trace trace, in parameters_trace copy)
{
    trace.position      = copy.position;
    trace.texel         = copy.texel;
    trace.coords        = copy.coords;
    trace.normal        = copy.normal;
    trace.gradient      = copy.gradient;
    trace.color         = copy.color;
    trace.shading       = copy.shading;
    trace.value         = copy.value;
    trace.error         = copy.error;
    trace.distance      = copy.distance;
    trace.depth         = copy.depth;
    trace.dithering     = copy.dithering;
    trace.stepping      = copy.skipped;
    trace.skipped       = copy.skipped;
    trace.spacing       = copy.spacing;
    trace.gradient_norm = copy.gradient_norm;
    trace.derivative    = copy.derivative;
    trace.derivative2   = copy.derivative2;
    trace.derivative3   = copy.derivative3;
    trace.steps         = copy.steps;
}


#endif
