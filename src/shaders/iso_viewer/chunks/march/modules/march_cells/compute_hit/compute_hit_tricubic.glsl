
// // Construct the quintic coefficients
// mat4x3 residuals = transpose(quintic.biases) * quintic.features - u_volume.isovalue;
// mat4x3 coeffs = quad_inv_vander * residuals * cubic_inv_vander;
// sum_anti_diags(coeffs, quintic.coeffs);

// Compute quintic polynomial roots in [0, 1]
poly5_roots(quintic.roots, quintic.coeffs, 0.0, 1.0);
quintic.root = mmin(quintic.roots);

// Compute derivative at root
eval_poly(quintic.coeffs, quintic.root, hit.derivative);

// Compute orientation
hit.orientation = -ssign(hit.derivative); 
hit.derivative /= cell.span_distance;

// Compute intersection distance
hit.distance = mix(cell.entry_distance, cell.exit_distance, quintic.root);
hit.position = camera.position + ray.direction * hit.distance;

// Sample value
hit.value = sample_value_tricubic(hit.position);
hit.residue = hit.value - u_volume.isovalue;

// Compute gradients and hessian
hit.gradient = compute_gradient(hit.position, hit.hessian);
hit.gradient *= hit.orientation; 
hit.hessian *= hit.orientation;

// Compute normal
hit.normal = normalize(hit.gradient);

// Compute principal curvatures
hit.curvatures = principal_curvatures(hit.gradient, hit.hessian);
