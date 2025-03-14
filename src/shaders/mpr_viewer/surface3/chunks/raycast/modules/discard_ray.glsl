
#if DISCARDING_DISABLED == 0
discard;  
#else
ray.discarded = true;
#endif