// Reuse the shared features vector at t = 0 by copying the last sample from the previous cell
quintic.features[0] = quintic.features[3];

// Sample the tricubic function at interior positions along the ray segment
#pragma unroll
for (int i = 1; i < 4; i++) 
{
    // Compute sampling position along the ray at normalized location sampling_points[i]
    vec3 position = mix(cell.entry_position, cell.exit_position, sampling_points[i]);

    // Sample the packed tricubic features: (fxx, fyy, fzz, f)
    quintic.features[i] = tricubic_features(position);

    // Compute the bias vector corresponding to quadratic correction terms
    quintic.biases[i - 1] = tricubic_bias(position);
}

// Construct the residual matrix: subtract isovalue from interpolated samples
// Resulting residuals encode scalar deviation from the isovalue at each sample point
mat4x3 residuals = transpose(quintic.biases) * quintic.features - u_volume.isovalue;

// Extract the residual values along the diagonal
// Also propagate the initial sample from the previous cell
quintic.residuals = vec4(quintic.residuals[3], residuals[1][0], residuals[2][1], residuals[3][2]);
