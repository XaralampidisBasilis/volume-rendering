/* Sources
One Step Further Beyond Trilinear Interpolation and Central
Differences: Triquadratic Reconstruction and its Analytic
Derivatives at the Cost of One Additional Texture Fetch 
(https://onlinelibrary.wiley.com/doi/10.1111/cgf.14753),

GPU Gems 2, Chapter 20. Fast Third-Order Texture Filtering 
(https://developer.nvidia.com/gpugems/gpugems2/part-iii-high-quality-rendering/chapter-20-fast-third-order-texture-filtering),
*/
#ifndef COMPUTE_GRADIENT_TRIQUADRATIC_BSPLINE
#define COMPUTE_GRADIENT_TRIQUADRATIC_BSPLINE

#ifndef SAMPLE_TRILINEAR_VOLUME
#include "../sample_value_trilinear"
#endif
#ifndef SAMPLE_TRICUBIC_VOLUME
#include "../sample_value_tricubic"
#endif
#ifndef SAMPLE_SECOND_DERIVATIVES
#include "../sample_second_derivatives"
#endif

/*
    The gradients produced are C^1 continuous
*/
vec3 compute_gradient_triquadratic_bspline(in vec3 p)
{
    // Convert to voxel-space and compute local coordinates
    vec3 x = p - 0.5;
    vec3 b = x - round(x);

    // 1D B-spline filter coefficients for each axis
    vec3 g0 = 0.5 - b;

    // 1D B-spline filter offsets for each axis
    vec3 h0 = (0.5 + b) * 0.5;

    // 1D B-spline filter normalized positions for each axis
    vec3 p0 = p - h0;
    vec3 p1 = p0 + 0.5;
 
    // Cube samples
    vec4 s_x0y0z0_x0y1z0_x0y0z1_x0y1z1 = vec4(
        sample_value_trilinear(vec3(p0.x, p0.y, p0.z)), 
        sample_value_trilinear(vec3(p0.x, p1.y, p0.z)), 
        sample_value_trilinear(vec3(p0.x, p0.y, p1.z)), 
        sample_value_trilinear(vec3(p0.x, p1.y, p1.z))  
    );

    vec4 s_x1y0z0_x1y1z0_x1y0z1_x1y1z1 = vec4(
        sample_value_trilinear(vec3(p1.x, p0.y, p0.z)), 
        sample_value_trilinear(vec3(p1.x, p1.y, p0.z)), 
        sample_value_trilinear(vec3(p1.x, p0.y, p1.z)), 
        sample_value_trilinear(vec3(p1.x, p1.y, p1.z))  
    );

    // Interpolate along x
    vec4 s_xy0z0_xy1z0_xy0z1_xy1z1 = mix(
        s_x1y0z0_x1y1z0_x1y0z1_x1y1z1, 
        s_x0y0z0_x0y1z0_x0y0z1_x0y1z1, 
    g0.x);

    // Differentiate across x
    vec4 s_dxy0z0_dxy1z0_dxy0z1_dxy1z1 = (
        s_x1y0z0_x1y1z0_x1y0z1_x1y1z1 - 
        s_x0y0z0_x0y1z0_x0y0z1_x0y1z1
    ) * 2.0;

    // Interpolate along y
    vec4 s_xyz0_xyz1_dxyz0_dxyz1 = mix(
        vec4(s_xy0z0_xy1z0_xy0z1_xy1z1.yw, s_dxy0z0_dxy1z0_dxy0z1_dxy1z1.yw),
        vec4(s_xy0z0_xy1z0_xy0z1_xy1z1.xz, s_dxy0z0_dxy1z0_dxy0z1_dxy1z1.xz),
    g0.y);

    // Differentiate across y
    vec2 s_xdyz0_xdyz1 = (
        s_xy0z0_xy1z0_xy0z1_xy1z1.yw - 
        s_xy0z0_xy1z0_xy0z1_xy1z1.xz
    ) * 2.0;

    // Interpolate along z
    vec2 s_dxyz_xdyz = mix(
        vec2(s_xyz0_xyz1_dxyz0_dxyz1.w, s_xdyz0_xdyz1.y),
        vec2(s_xyz0_xyz1_dxyz0_dxyz1.z, s_xdyz0_xdyz1.x), 
    g0.z);

    // Differentiate across z
    float s_xydz = (
        s_xyz0_xyz1_dxyz0_dxyz1.y - 
        s_xyz0_xyz1_dxyz0_dxyz1.x
    ) * 2.0;

    // Gradient
    vec3 gradient = vec3(s_dxyz_xdyz, s_xydz);

    // Account for anisotropy in physical space
    gradient /= u_volume.spacing;

    return gradient;
}
 
vec3 compute_gradient_triquadratic_bspline(in vec3 p, out mat3 hessian)
{
    // Convert to voxel-space and compute local coordinates
    vec3 x = p - 0.5;
    vec3 b = x - round(x);

    // 1D B-spline filter coefficients for each axis
    vec3 g0 = 0.5 - b;

    // 1D B-spline filter offsets for each axis
    vec3 h0 = (0.5 + b) * 0.5;

    // 1D B-spline filter normalized positions for each axis
    vec3 p0 = p - h0;
    vec3 p1 = p0 + 0.5;

    // Cube samples
    vec4 s_x0y0z0_x0y1z0_x0y0z1_x0y1z1 = vec4(
        sample_value_trilinear(vec3(p0.x, p0.y, p0.z)), 
        sample_value_trilinear(vec3(p0.x, p1.y, p0.z)), 
        sample_value_trilinear(vec3(p0.x, p0.y, p1.z)), 
        sample_value_trilinear(vec3(p0.x, p1.y, p1.z))  
    );

    vec4 s_x1y0z0_x1y1z0_x1y0z1_x1y1z1 = vec4(
        sample_value_trilinear(vec3(p1.x, p0.y, p0.z)), 
        sample_value_trilinear(vec3(p1.x, p1.y, p0.z)), 
        sample_value_trilinear(vec3(p1.x, p0.y, p1.z)), 
        sample_value_trilinear(vec3(p1.x, p1.y, p1.z))  
    );

    // Interpolate along x
    vec4 s_xy0z0_xy1z0_xy0z1_xy1z1 = mix(
        s_x1y0z0_x1y1z0_x1y0z1_x1y1z1, 
        s_x0y0z0_x0y1z0_x0y0z1_x0y1z1, 
    g0.x);

    // Differentiate across x
    vec4 s_dxy0z0_dxy1z0_dxy0z1_dxy1z1 = (
        s_x1y0z0_x1y1z0_x1y0z1_x1y1z1 - 
        s_x0y0z0_x0y1z0_x0y0z1_x0y1z1
    ) * 2.0;

    // Interpolate along y
    vec4 s_xyz0_xyz1_dxyz0_dxyz1 = mix(
        vec4(s_xy0z0_xy1z0_xy0z1_xy1z1.yw, s_dxy0z0_dxy1z0_dxy0z1_dxy1z1.yw),
        vec4(s_xy0z0_xy1z0_xy0z1_xy1z1.xz, s_dxy0z0_dxy1z0_dxy0z1_dxy1z1.xz),
    g0.y);

    // Differentiate across y
    vec4 s_xdyz0_xdyz1_dxdyz0_dxdyz1 = (
        vec4(s_xy0z0_xy1z0_xy0z1_xy1z1.yw, s_dxy0z0_dxy1z0_dxy0z1_dxy1z1.yw) -
        vec4(s_xy0z0_xy1z0_xy0z1_xy1z1.xz, s_dxy0z0_dxy1z0_dxy0z1_dxy1z1.xz)
    ) * 2.0;

    // Interpolate along z
    vec3 s_dxyz_xdyz_dxdyz = mix(
        vec3(s_xyz0_xyz1_dxyz0_dxyz1.w, s_xdyz0_xdyz1_dxdyz0_dxdyz1.yw),
        vec3(s_xyz0_xyz1_dxyz0_dxyz1.z, s_xdyz0_xdyz1_dxdyz0_dxdyz1.xz), 
    g0.z);

    // Differentiate across z
    vec3 s_xydz_dxydz_xdydz = (
        vec3(s_xyz0_xyz1_dxyz0_dxyz1.yw, s_xdyz0_xdyz1_dxdyz0_dxdyz1.y) -
        vec3(s_xyz0_xyz1_dxyz0_dxyz1.xz, s_xdyz0_xdyz1_dxdyz0_dxdyz1.x)
    ) * 2.0;

    // Pure second derivatives
    vec3 s_d2x_d2y_d2z = sample_second_derivatives(p);

    // Gradient
    vec3 gradient = vec3(s_dxyz_xdyz_dxdyz.xy, s_xydz_dxydz_xdydz.x);

    // Hessian
    hessian = mat3(
        s_d2x_d2y_d2z.x, s_dxyz_xdyz_dxdyz.z, s_xydz_dxydz_xdydz.y,  
        s_dxyz_xdyz_dxdyz.z, s_d2x_d2y_d2z.y, s_xydz_dxydz_xdydz.z,  
        s_xydz_dxydz_xdydz.y, s_xydz_dxydz_xdydz.z, s_d2x_d2y_d2z.z     
    );

    // Account for anisotropy in physical space
    hessian /= outerProduct(u_volume.spacing, u_volume.spacing);
    gradient /= u_volume.spacing;

    // Return Gradient
    return gradient;
}

#endif