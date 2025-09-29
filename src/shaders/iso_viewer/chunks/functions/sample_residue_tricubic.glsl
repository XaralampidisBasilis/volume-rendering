
#ifndef SAMPLE_RESIDUE_TRICUBIC
#define SAMPLE_RESIDUE_TRICUBIC

#ifndef SAMPLE_VALUE_TRICUBIC
#include "./sample_value_tricubic"
#endif

float sample_residue_tricubic(in vec3 coords)
{
    return sample_value_tricubic(coords) - u_volume.isovalue;
}

float sample_residue_tricubic(in vec3 coords, out vec4 features)
{
    return sample_value_tricubic(coords, features) - u_volume.isovalue;
}

#endif