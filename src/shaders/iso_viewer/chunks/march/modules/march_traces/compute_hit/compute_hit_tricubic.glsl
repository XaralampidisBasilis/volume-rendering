
// Define brackets
vec2 distances = vec2(trace.prev_distance, trace.distance);
vec2 residues = vec2(trace.prev_residue, trace.residue);

#pragma unroll
for (int i = 0; i < 10; ++i)
{
    // Neubauer update
    hit.derivative = diff(residues) / diff(distances);
    hit.distance = distances.x - residues.x / hit.derivative;
    hit.position = camera.position + ray.direction * hit.distance; 

    // evaluate polynomial
    hit.residue = sample_value_tricubic(hit.position) - u_volume.isovalue;
    
    // determine bracket based on sign
    if (sign_change(residues.x, hit.residue))
    {
        distances.y = hit.distance;
        residues.y = hit.residue;
    }
    else
    {
        distances.x = hit.distance;
        residues.x = hit.residue;
    }
}

// Compute value
hit.value = hit.residue + u_volume.isovalue;

// Compute orientation
hit.orientation = -ssign(hit.derivative);

// Compute gradients and hessian
hit.gradient = compute_gradient(hit.position, hit.hessian);
hit.gradient *= hit.orientation; 
hit.hessian *= hit.orientation;

// Compute normal
hit.normal = normalize(hit.gradient);

// Compute principal curvatures
hit.curvatures = principal_curvatures(hit.gradient, hit.hessian);
