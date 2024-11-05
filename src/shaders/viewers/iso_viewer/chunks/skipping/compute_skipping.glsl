
#if VOLUME_SKIP_BBOX_ENABLED == 1  
    #include "./skipping_bbox"

#endif // HAS_BBOX

#if VOLUME_SKIP_OCCUMAPS_ENABLED == 1
    #include "./skipping_occumaps"
#endif // HAS_SKIPPING
