
#if SKIPPING_METHOD == 0

    #include "./update_block/update_block_occupancy"

#endif
#if SKIPPING_METHOD == 1

    #include "./update_block/update_block_isotropic"
    
#endif
#if SKIPPING_METHOD == 2

    #include "./update_block/update_block_anisotropic"

#endif
#if SKIPPING_METHOD == 3

    #include "./update_block/update_block_extended"

#endif    
#if SKIPPING_METHOD == 4

    #include "./update_block/update_block_extended_isotropic"

#endif    
