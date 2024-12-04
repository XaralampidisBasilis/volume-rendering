#ifndef STRUCT_VOXEL
#define STRUCT_VOXEL

struct Voxel 
{
    ivec3 coords;               // integer coordinates
    vec3  texture_coords;       // normalized texture coordinates

    float value;                // sampled value at the current position
    float value_error;          // sampled error associated with the difference of the sample value from the threshold
    
    vec3  normal;               // normal vector
    vec3  gradient;             // gradient vector
    vec3  gradient_direction;   // direction of the gradient vector
    float gradient_magnitude;   // magnitude of the gradient vector
    float derivative;           // directional derivative at the sample position

    vec4  mapped_color;         // color mapped from the sample value
    vec4  shaded_color;         // color after shading has been applied
};

Voxel set_voxel()
{
    Voxel voxel;
    voxel.value              = 0.0;
    voxel.value_error        = 0.0;
    voxel.coords       = ivec3(0);
    voxel.texture_coords       = vec3(0.0);
    voxel.normal             = vec3(0.0);
    voxel.gradient           = vec3(0.0);
    voxel.gradient_direction = vec3(0.0);
    voxel.gradient_magnitude = 0.0;
    voxel.derivative         = 0.0;
    voxel.mapped_color       = vec4(vec3(0.0), 1.0);
    voxel.shaded_color       = vec4(vec3(0.0), 1.0);
    return voxel;
}
void discard_voxel(inout Voxel voxel)
{
    voxel.value              = voxel.value;              
    voxel.value_error        = voxel.value_error;        
    voxel.coords       = voxel.coords;       
    voxel.texture_coords       = voxel.texture_coords;       
    voxel.normal             = voxel.normal;             
    voxel.gradient           = voxel.gradient;           
    voxel.gradient_direction = voxel.gradient_direction; 
    voxel.gradient_magnitude = voxel.gradient_magnitude; 
    voxel.derivative         = voxel.derivative;         
    voxel.mapped_color       = voxel.mapped_color;       
    voxel.shaded_color       = voxel.shaded_color;       
}


#endif // STRUCT_VOXEL
