
#if VOLUME_SKIP_BBOX_ENABLED == 1  
    #include "./modules/skipping_bbox"

#endif // HAS_BBOX

#if VOLUME_SKIP_OMAPS_ENABLED == 1
    #include "./modules/skipping_occumaps"

#endif // HAS_SKIPPING
