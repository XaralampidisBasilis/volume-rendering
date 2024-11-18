#if TRACE_POSITION_REFINEMENT_ENABLED == 1
#include "./compute_position_refinement"
#endif

// case trace suspended
if (trace.suspended) {}

// case trace terminated
if (trace.terminated) {}

// update mean cummulative values
trace.mean_step_scaling /= float(trace.step_count);
trace.mean_step_distance /= float(trace.step_count);
