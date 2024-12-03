// discard fragment
#if FRAGMENT_DISCARDING_DISABLED == 0
discard;  
#else
discard_trace(trace);
#endif