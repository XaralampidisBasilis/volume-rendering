
#if FRAGMENT_DISCARDING_DISABLED == 0
discard;  
#else
discard_ray(ray);
#endif