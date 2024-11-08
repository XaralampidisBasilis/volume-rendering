
// trace.step_stretching = 1.0 + 2.0 * trace.distance * u_volume.inv_size_length);
trace.step_stretching = exp(2.0 * trace.distance * u_volume.inv_size_length);
