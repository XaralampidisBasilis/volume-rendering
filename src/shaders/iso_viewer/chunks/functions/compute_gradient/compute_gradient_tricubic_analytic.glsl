/* Source:
   Beyond Trilinear Interpolation: Higher Quality for Free
   https://dl.acm.org/doi/10.1145/3306346.3323032
*/
#ifndef COMPUTE_GRADIENT_TRICUBIC_ANALYTIC
#define COMPUTE_GRADIENT_TRICUBIC_ANALYTIC

#ifndef SAMPLE_TRICUBIC_VOLUME
#include "../sample_value_tricubic"
#endif

/*
    This function produces analytic gradients and curvatures directly from the 
    interpolation function described in "Beyond Trilinear Interpolation: Higher Quality for Free".
    There are some visible boundary artifacts between cells because gradients are C^0 piecewise continuous 
*/
vec3 compute_gradient_tricubic_analytic(in vec3 p)
{
    // Convert to voxel-space and compute local coordinates
    vec3 x = p - 0.5; // to cell space
    vec3 i = floor(x); // cell index

    vec3 a0 = x - i; // cell space coordinates
    vec3 a1 = a0 - 0.5;

    vec3 p0 = i + 0.5;
    vec3 p1 = i + 1.5;

    vec4 bias = vec4(a0 * (a0 - 1.0) * 0.5, 1.0);

    // Take cross samples
    vec4 f    = tricubic_features(p);
    vec4 f_x0 = tricubic_features(vec3(p0.x, p.y,  p.z));
    vec4 f_x1 = tricubic_features(vec3(p1.x, p.y,  p.z));
    vec4 f_y0 = tricubic_features(vec3(p.x,  p0.y, p.z));
    vec4 f_y1 = tricubic_features(vec3(p.x,  p1.y, p.z));
    vec4 f_z0 = tricubic_features(vec3(p.x,  p.y,  p0.z));
    vec4 f_z1 = tricubic_features(vec3(p.x,  p.y,  p1.z));

    // Central differences
    vec4 f_dx = f_x1 - f_x0;
    vec4 f_dy = f_y1 - f_y0;
    vec4 f_dz = f_z1 - f_z0;

    // first partial derivatives
    float F_dx = dot(f_dx, bias) + f.x * a1.x;
    float F_dy = dot(f_dy, bias) + f.y * a1.y;
    float F_dz = dot(f_dz, bias) + f.z * a1.z;

    // Gradient
    vec3 gradient = vec3(F_dx, F_dy, F_dz);

    // Account for anisotropy in physical space
    gradient /= u_volume.spacing;

    return gradient;
}

vec3 compute_gradient_tricubic_analytic(in vec3 p, out mat3 hessian)
{
    // Convert to voxel-space and compute local coordinates
    vec3 x = p - 0.5; // cell offset
    vec3 i = floor(x); // cell coords [0, N]

    vec3 a0 = x - i; // cell space [0, 1]
    vec3 a1 = a0 - 0.5;

    vec3 p0 = i + 0.5;
    vec3 p1 = i + 1.5;

    vec4 bias = vec4(a0 * (a0 - 1.0) * 0.5, 1.0);

    // Take cube samples
    vec4 f_x0y0z0 = tricubic_features(vec3(p0.x, p0.y, p0.z));
    vec4 f_x0y1z0 = tricubic_features(vec3(p0.x, p1.y, p0.z));
    vec4 f_x0y0z1 = tricubic_features(vec3(p0.x, p0.y, p1.z));
    vec4 f_x0y1z1 = tricubic_features(vec3(p0.x, p1.y, p1.z));
    vec4 f_x1y0z0 = tricubic_features(vec3(p1.x, p0.y, p0.z));
    vec4 f_x1y1z0 = tricubic_features(vec3(p1.x, p1.y, p0.z));
    vec4 f_x1y0z1 = tricubic_features(vec3(p1.x, p0.y, p1.z));
    vec4 f_x1y1z1 = tricubic_features(vec3(p1.x, p1.y, p1.z));

    // Interpolate along x
    vec4 f_xy0z0 = mix(f_x0y0z0, f_x1y0z0, a0.x);
    vec4 f_xy1z0 = mix(f_x0y1z0, f_x1y1z0, a0.x);
    vec4 f_xy0z1 = mix(f_x0y0z1, f_x1y0z1, a0.x);
    vec4 f_xy1z1 = mix(f_x0y1z1, f_x1y1z1, a0.x);

    // Differentiate across x
    vec4 f_dxy0z0 = f_x1y0z0 - f_x0y0z0;
    vec4 f_dxy1z0 = f_x1y1z0 - f_x0y1z0;
    vec4 f_dxy0z1 = f_x1y0z1 - f_x0y0z1;
    vec4 f_dxy1z1 = f_x1y1z1 - f_x0y1z1;

    // Interpolate along y
    vec4 f_xyz0  = mix(f_xy0z0,  f_xy1z0,  a0.y);
    vec4 f_xyz1  = mix(f_xy0z1,  f_xy1z1,  a0.y);
    vec4 f_dxyz0 = mix(f_dxy0z0, f_dxy1z0, a0.y);
    vec4 f_dxyz1 = mix(f_dxy0z1, f_dxy1z1, a0.y);

    // Differentiate across y
    vec4 f_xdyz0  = f_xy1z0  - f_xy0z0;
    vec4 f_xdyz1  = f_xy1z1  - f_xy0z1;
    vec4 f_dxdyz0 = f_dxy1z0 - f_dxy0z0;
    vec4 f_dxdyz1 = f_dxy1z1 - f_dxy0z1;

    // Interpolate along z
    vec4 f_xyz   = mix(f_xyz0,   f_xyz1,   a0.z);
    vec4 f_dxyz  = mix(f_dxyz0,  f_dxyz1,  a0.z);
    vec4 f_xdyz  = mix(f_xdyz0,  f_xdyz1,  a0.z);
    vec4 f_dxdyz = mix(f_dxdyz0, f_dxdyz1, a0.z);

    // Differentiate across z
    vec4 f_xydz  = f_xyz1  - f_xyz0;
    vec4 f_dxydz = f_dxyz1 - f_dxyz0;
    vec4 f_xdydz = f_xdyz1 - f_xdyz0;

    // first partial derivatives
    float Fx_xyz = dot(f_dxyz, bias) + f_xyz.x * a1.x;
    float Fy_xyz = dot(f_xdyz, bias) + f_xyz.y * a1.y;
    float Fz_xyz = dot(f_xydz, bias) + f_xyz.z * a1.z;

    // Second mixed derivatives
    float Fxy_xyz = dot(f_dxdyz, bias) + dot(vec2(f_xdyz.x, f_dxyz.y), a1.xy);
    float Fyz_xyz = dot(f_xdydz, bias) + dot(vec2(f_xydz.y, f_xdyz.z), a1.yz);
    float Fxz_xyz = dot(f_dxydz, bias) + dot(vec2(f_dxyz.z, f_xydz.x), a1.zx);

    // Second pure derivatives
    float Fxx_xyz = f_xyz.x + f_dxyz.x * a1.x * 2.0;
    float Fyy_xyz = f_xyz.y + f_xdyz.y * a1.y * 2.0;
    float Fzz_xyz = f_xyz.z + f_xydz.z * a1.z * 2.0;

    // Gradient
    vec3 gradient = vec3(Fx_xyz, Fy_xyz, Fz_xyz);

    // Hessian
    hessian = mat3(
        Fxx_xyz, Fxy_xyz, Fxz_xyz,  
        Fxy_xyz, Fyy_xyz, Fyz_xyz,  
        Fxz_xyz, Fyz_xyz, Fzz_xyz     
    );

    // Account for anisotropy in physical space
    hessian /= outerProduct(u_volume.spacing, u_volume.spacing);
    gradient /= u_volume.spacing;

    return gradient;
}



#endif