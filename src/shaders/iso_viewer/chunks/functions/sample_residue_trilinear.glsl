
#ifndef SAMPLE_RESIDUE_TRILINEAR
#define SAMPLE_RESIDUE_TRILINEAR

#ifndef SAMPLE_VALUE_TRILINEAR
#include "./sample_value_trilinear"
#endif

float sample_residue_trilinear(in vec3 coords)
{
    return sample_value_trilinear(coords) - u_volume.isovalue;
}

#endif