#ifndef UTILS_RAMPSTEP
#define UTILS_RAMPSTEP

/**
 * @brief Computes a linear ramp function.
 * 
 * This function computes a linear ramp based on the input value x and the edges edge0 and edge1.
 * The output is clamped to the range [0.0, 1.0]. 
 * 
 * @param edge0 The lower edge of the ramp. Values less than or equal to edge0 will result in an output of 0.0.
 * @param edge1 The upper edge of the ramp. Values greater than or equal to edge1 will result in an output of 1.0.
 * @param x The input value for which the ramp function is computed.
 * 
 * @return The computed ramp value, clamped to the range [0.0, 1.0].
 */

float rampstep
(
    float edge0, 
    float edge1, 
    float x
) 
{
    return clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
}

#endif // UTILS_RAMPSTEP