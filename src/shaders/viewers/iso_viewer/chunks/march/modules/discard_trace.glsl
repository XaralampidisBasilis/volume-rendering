// discard fragment
#if FRAGMENT_DISCARDING_DISABLED == 0
discard;  
#else
trace = set_trace();
#endif