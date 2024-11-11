
// terminate ray parameters
ray = set_ray();

// discard fragment
#if TRACE_DISCARDING_DISABLED == 0
discard;  
#endif