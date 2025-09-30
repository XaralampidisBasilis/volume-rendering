
#if MARCHING_METHOD == 0

    #if SKIPPING_ENABLED == 1

        #include "./modules/march_cells/march_cells_skipping"

    #else

        #include "./modules/march_cells/march_cells_baseline"
        
    #endif

#endif

#if MARCHING_METHOD == 1

    #if SKIPPING_ENABLED == 1

        #include "./modules/march_traces/march_traces_skipping"

    #else

        #include "./modules/march_traces/march_traces_baseline"
        
    #endif

#endif
