#ifndef PARAMETERS_TRACE
#define PARAMETERS_TRACE

// Struct to hold information about a ray trace intersection in normalized coordinates
struct parameters_trace 
{
    vec4  gradial_data;
    vec3  position;   // position in model space
    vec3  texel;      // normalized texture coordinates
    vec3  normal;     // normal in model space
    vec3  gradient;   // gradient in model space
    vec3  color;
    vec3  lighting;
    float value;     // Scalar value at the intersection
    float error;
    float depth;     // Distance the ray has traveled to the intersection
    float steepness; // The normalized length of the gradient vector
    float spacing;
    float dithering;  
    int   i_step;
};

void set_trace(inout parameters_trace trace)
{
    trace.gradial_data = vec4(0.0);
    trace.position     = vec3(0.0);
    trace.texel        = vec3(0.0);
    trace.normal       = vec3(0.0); 
    trace.gradient     = vec3(0.0); 
    trace.color        = vec3(0.0);
    trace.lighting     = vec3(0.0);
    trace.value        = 0.0;  
    trace.error        = 0.0;  
    trace.depth        = 0.0;
    trace.steepness    = 0.0;    
    trace.spacing      = 0.0;
    trace.dithering    = 0.0;
    trace.i_step       = 0;
}

void copy_trace(inout parameters_trace trace, in parameters_trace copy)
{
    trace.gradial_data = copy.gradial_data;
    trace.position     = copy.position ;
    trace.texel        = copy.texel;
    trace.normal       = copy.normal;
    trace.gradient     = copy.gradient;
    trace.color        = copy.color;
    trace.lighting     = copy.lighting;
    trace.value        = copy.value;
    trace.error        = copy.error;
    trace.depth        = copy.depth;
    trace.steepness    = copy.steepness;
    trace.spacing      = copy.spacing;
    trace.dithering    = copy.dithering ;
    trace.i_step       = copy.i_step;
}


#endif
