
// // Compute cubic coefficients
// cubic.coeffs = cubic.residuals * cubic_inv_vander;

// Compute cubic polynomial roots in [0, 1]
poly3_roots(cubic.roots, cubic.coeffs, 0.0, 1.0);
cubic.root = mmin(cubic.roots);

// Compute cubic derivative at min root
eval_poly(cubic.coeffs, cubic.root, hit.derivative);

// Compute orientation
hit.orientation = -ssign(hit.derivative); 
hit.derivative /= cell.span_distance;

// Compute intersection distance/position
hit.distance = mix(cell.entry_distance, cell.exit_distance, cubic.root);
hit.position = camera.position + ray.direction * hit.distance;

// Sample value/residue
hit.value = sample_value_trilinear(hit.position);
hit.residue = hit.value - u_volume.isovalue;

// Compute gradients and hessian
hit.gradient = compute_gradient(hit.position, hit.hessian);
hit.gradient *= hit.orientation; 
hit.hessian *= hit.orientation;

// Compute normal
hit.normal = normalize(hit.gradient);

// Compute principal curvatures
hit.curvatures = principal_curvatures(hit.gradient, hit.hessian);
