/** slower version
float hermite_interpolation
(
    in float v0,
    in float v1,
    in float d0,
    in float d1,
    in float t
)
{
    float t2 = t * t;
    float t3 = t2 * t;

    // Hermite basis functions
    float h00 = 2.0 * t3 - 3.0 * t2 + 1.0;
    float h01 = -2.0 * t3 + 3.0 * t2;
    float h10 = t3 - 2.0 * t2 + t;
    float h11 = t3 - t2;

    // Compute the interpolation
    return h00 * v0 + h01 * v1 + h11 * d1 + h10 * d0 ;
}
*/

float hermite_interpolation
(
    in float v0,
    in float v1,
    in float d0,
    in float d1,
    in float t
)
{
    float t2 = t * t;
    float smooth_t = t2 * (3.0 - 2.0 * t); // based on smoothstep function smoothstep(0.0, 1.0, t);
    float smooth_v = mix(v0, v1, smooth_t);
    float smooth_d = mix(d0, -d1, t);

    return smooth_v + smooth_d * (t - t2);
}
