#ifndef SAMPLE_SECOND_DERIVATIVES
#define SAMPLE_SECOND_DERIVATIVES

#ifndef SAMPLE_TRILINEAR_VOLUME
#include "./sample_value_trilinear"
#endif

vec3 sample_second_derivatives(in vec3 p)
{
    #if INTERPOLATION_METHOD == 0

        // Central differencing samples
        vec3 s_x0yz_xy0z_xyz0 = vec3(
            sample_value_trilinear(vec3(p.x - 1.0, p.y, p.z)),
            sample_value_trilinear(vec3(p.x, p.y - 1.0, p.z)),
            sample_value_trilinear(vec3(p.x, p.y, p.z - 1.0))
        );

        vec3 s_x1yz_xy1z_xyz1 = vec3(
            sample_value_trilinear(vec3(p.x + 1.0, p.y, p.z)),
            sample_value_trilinear(vec3(p.x, p.y + 1.0, p.z)),
            sample_value_trilinear(vec3(p.x, p.y, p.z + 1.0))
        );

        // Pure second derivatives
        return s_x0yz_xy0z_xyz0 + s_x1yz_xy1z_xyz1 - sample_value_trilinear(p) * 2.0;

    #endif

    #if INTERPOLATION_METHOD == 1

        return tricubic_features(p).xyz;

    #endif
}

#endif