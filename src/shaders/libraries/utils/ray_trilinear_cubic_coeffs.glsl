#ifndef RAY_TRILINEAR_CUBIC_COEFFS
#define RAY_TRILINEAR_CUBIC_COEFFS

/**
 * Computes the cubic polynomial coefficients for the trilinear interpolation 
 * value along a ray passing through a 3D cell.
 * 
 * Given the values at the 8 vertices of a 3D cell (voxel), the start point of a ray, 
 * and its direction, this function calculates the coefficients of a cubic polynomial:
 * value(r(t)) = coeffs[0] + coeffs[1] * t + coeffs[2] * t^2 + coeffs[3] * t^3
 * 
 * The polynomial represents the interpolated scalar value along the ray as a 
 * function of the ray parameter t, r(t) = ray_origin + ray_direction * t.
 * 
 * @param f  Array of 8 scalar values corresponding to the vertices of the cell,
 *                       ordered as: [f000, f100, f010, f001, f011, f101, f110, f111].
 * @param ray_origin  The starting position of the ray in normalized cell coordinates. 
                         ex ray_origin = (ray_origin - cell_min_position) / cell_size
 * @param ray_direction  The the direction of the ray in normalized cell coordinates. 
                         ex ray_direction = ray_direction / cell_size
 * 
 * @return vec4          A vector containing the cubic polynomial coefficients 
 *                       [coeffs[0], coeffs[1], coeffs[2], coeffs[3]].
 * 
 * Reference:
 * https://www.wikiwand.com/en/Trilinear_interpolation
 */
vec4 ray_trilinear_cubic_coeffs(in vec3 f[8], in vec3 ray_origin, in vec3 ray_direction)
{
    // Compute vertex value differences to simplify computations
    vec3 F[8]
    F[0] = f[0];
    F[1] = f[1] - f[0];
    F[2] = f[2] - f[0];
    F[3] = f[3] - f[0];
    F[4] = f[4] - f[3] - f[2] + f[0];
    F[5] = f[5] - f[3] - f[1] + f[0];
    F[6] = f[6] - f[2] - f[1] + f[0];
    F[7] = f[7] - f[6] - f[5] - f[4] + f[3] + f[2] + f[1] - f[0]; 

    // Compute grouping vectors for optimization
    vec4 F1 = vec4(F[1], F[2], F[3], F[7]);
    vec4 F2 = vec4(F[4], F[5], F[6], F[7]);
    vec4 O1 = vec4(ray_origin, 1.0);
    vec4 D1 = vec4(ray_direction, 1.0);
    vec4 O2 = O1.yxxw * O1.zzyw;
    vec4 D2 = D1.yxxw * D1.zzyw;

    // Compute cubic coeffs with grouped vector operations
    vec4 coeffs = vec4(

        prod(O1) * F[7] + F[0]
            + dot(F1.xyz, O1.xyz) 
            + dot(F2.xyz, O2.xyz),

        dot(D2.xyz, vec3(
            dot(F2.zy, O1.yz) + dot(F1.wx, O2.xw), 
            dot(F2.zx, O1.xz) + dot(F1.wy, O2.yw), 
            dot(F2.yx, O1.xy) + dot(F1.wz, O2.zw))),

        dot(D1.xyz, vec3(
            dot(F2.zy, O1.yz) + dot(F1.wx, O2.xw), 
            dot(F2.zx, O1.xz) + dot(F1.wy, O2.yw), 
            dot(F2.yx, O1.xy) + dot(F1.wz, O2.zw))),

        prod(D1) * F[7]
    );

    return coeffs;
}

#endif // RAY_TRILINEAR_CUBIC_COEFFS
