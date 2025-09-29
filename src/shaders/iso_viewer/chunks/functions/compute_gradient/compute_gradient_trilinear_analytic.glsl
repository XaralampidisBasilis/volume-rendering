#ifndef COMPUTE_GRADIENT_TRILINEAR_ANALYTIC
#define COMPUTE_GRADIENT_TRILINEAR_ANALYTIC

#ifndef SAMPLE_TRILINEAR_VOLUME
#include "../sample_value_trilinear"
#endif

vec3 compute_gradient_trilinear_analytic(in vec3 p)
{
    // Convert to voxel-space and compute local coordinates
    vec3 x = p - 0.5;     // cell space
    vec3 i = floor(x); // cell coords

    vec3 a0 = x - i; // cell space

    vec3 p0 = i + 0.5;
    vec3 p1 = i + 1.5;

    // Take cube samples
    float f_x0y0z0 = sample_value_trilinear(vec3(p0.x, p0.y, p0.z));
    float f_x0y1z0 = sample_value_trilinear(vec3(p0.x, p1.y, p0.z));
    float f_x0y0z1 = sample_value_trilinear(vec3(p0.x, p0.y, p1.z));
    float f_x0y1z1 = sample_value_trilinear(vec3(p0.x, p1.y, p1.z));
    float f_x1y0z0 = sample_value_trilinear(vec3(p1.x, p0.y, p0.z));
    float f_x1y1z0 = sample_value_trilinear(vec3(p1.x, p1.y, p0.z));
    float f_x1y0z1 = sample_value_trilinear(vec3(p1.x, p0.y, p1.z));
    float f_x1y1z1 = sample_value_trilinear(vec3(p1.x, p1.y, p1.z));

    // Interpolate along x
    float f_xy0z0 = mix(f_x0y0z0, f_x1y0z0, a0.x);
    float f_xy1z0 = mix(f_x0y1z0, f_x1y1z0, a0.x);
    float f_xy0z1 = mix(f_x0y0z1, f_x1y0z1, a0.x);
    float f_xy1z1 = mix(f_x0y1z1, f_x1y1z1, a0.x);

    // Differentiate across x
    float f_dxy0z0 = f_x1y0z0 - f_x0y0z0;
    float f_dxy1z0 = f_x1y1z0 - f_x0y1z0;
    float f_dxy0z1 = f_x1y0z1 - f_x0y0z1;
    float f_dxy1z1 = f_x1y1z1 - f_x0y1z1;

    // Interpolate along y
    float f_xyz0  = mix(f_xy0z0,  f_xy1z0,  a0.y);
    float f_xyz1  = mix(f_xy0z1,  f_xy1z1,  a0.y);
    float f_dxyz0 = mix(f_dxy0z0, f_dxy1z0, a0.y);
    float f_dxyz1 = mix(f_dxy0z1, f_dxy1z1, a0.y);

    // Differentiate across y
    float f_xdyz0 = f_xy1z0 - f_xy0z0;
    float f_xdyz1 = f_xy1z1 - f_xy0z1;

    // Interpolate along z
    float f_dxyz = mix(f_dxyz0, f_dxyz1, a0.z);
    float f_xdyz = mix(f_xdyz0, f_xdyz1, a0.z);

    // Differentiate across z
    float f_xydz = f_xyz1 - f_xyz0;

    // Gradient
    vec3 gradient = vec3(f_dxyz, f_xdyz, f_xydz);

    // Account for anisotropy in physical space
    gradient /= u_volume.spacing;

    return gradient;
}

vec3 compute_gradient_trilinear_analytic(in vec3 p, out mat3 hessian)
{
    // Convert to voxel-space and compute local coordinates
    vec3 x = p - 0.5; // cell offset
    vec3 i = floor(x); // cell coords [0, N]

    vec3 a0 = x - i; // cell space [0, 1]

    vec3 p0 = i + 0.5;
    vec3 p1 = i + 1.5;

    // Take cube samples
    float f_x0y0z0 = sample_value_trilinear(vec3(p0.x, p0.y, p0.z));
    float f_x0y1z0 = sample_value_trilinear(vec3(p0.x, p1.y, p0.z));
    float f_x0y0z1 = sample_value_trilinear(vec3(p0.x, p0.y, p1.z));
    float f_x0y1z1 = sample_value_trilinear(vec3(p0.x, p1.y, p1.z));
    float f_x1y0z0 = sample_value_trilinear(vec3(p1.x, p0.y, p0.z));
    float f_x1y1z0 = sample_value_trilinear(vec3(p1.x, p1.y, p0.z));
    float f_x1y0z1 = sample_value_trilinear(vec3(p1.x, p0.y, p1.z));
    float f_x1y1z1 = sample_value_trilinear(vec3(p1.x, p1.y, p1.z));

    // Interpolate along x
    float f_xy0z0 = mix(f_x0y0z0, f_x1y0z0, a0.x);
    float f_xy1z0 = mix(f_x0y1z0, f_x1y1z0, a0.x);
    float f_xy0z1 = mix(f_x0y0z1, f_x1y0z1, a0.x);
    float f_xy1z1 = mix(f_x0y1z1, f_x1y1z1, a0.x);

    // Differentiate across x
    float f_dxy0z0 = f_x1y0z0 - f_x0y0z0;
    float f_dxy1z0 = f_x1y1z0 - f_x0y1z0;
    float f_dxy0z1 = f_x1y0z1 - f_x0y0z1;
    float f_dxy1z1 = f_x1y1z1 - f_x0y1z1;

    // Interpolate along y
    float f_xyz0  = mix(f_xy0z0,  f_xy1z0,  a0.y);
    float f_xyz1  = mix(f_xy0z1,  f_xy1z1,  a0.y);
    float f_dxyz0 = mix(f_dxy0z0, f_dxy1z0, a0.y);
    float f_dxyz1 = mix(f_dxy0z1, f_dxy1z1, a0.y);

    // Differentiate across y
    float f_xdyz0  = f_xy1z0  - f_xy0z0;
    float f_xdyz1  = f_xy1z1  - f_xy0z1;
    float f_dxdyz0 = f_dxy1z0 - f_dxy0z0;
    float f_dxdyz1 = f_dxy1z1 - f_dxy0z1;

    // Interpolate along z
    float f_xyz   = mix(f_xyz0,   f_xyz1,   a0.z);
    float f_dxyz  = mix(f_dxyz0,  f_dxyz1,  a0.z);
    float f_xdyz  = mix(f_xdyz0,  f_xdyz1,  a0.z);
    float f_dxdyz = mix(f_dxdyz0, f_dxdyz1, a0.z);

    // Differentiate across z
    float f_xydz  = f_xyz1  - f_xyz0;
    float f_dxydz = f_dxyz1 - f_dxyz0;
    float f_xdydz = f_xdyz1 - f_xdyz0;

    // Gradient
    vec3 gradient = vec3(f_dxyz, f_xdyz, f_xydz);

    // Hessian
    hessian = mat3(
        0.0, f_dxdyz, f_dxydz,  
        f_dxdyz, 0.0, f_xdydz,  
        f_dxydz, f_xdydz, 0.0     
    );

    // Account for anisotropy in physical space
    hessian /= outerProduct(u_volume.spacing, u_volume.spacing);
    gradient /= u_volume.spacing;

    return gradient;
}

#endif