
#if FRAGMENT_DISCARDING_DISABLED == 0
discard;  
#else
ray = set_ray();
#endif