
// compute trace from block
trace.distance = block.entry_distance;
trace.position = block.entry_position;
trace.uvw = trace.position * u_volume.inv_dimensions;

// compute gradient at trace
#include "./compute_gradient_central"