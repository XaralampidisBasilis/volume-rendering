Camera camera = set_camera();
Box    box    = set_box();
Ray    ray    = set_ray();
Trace  trace  = set_trace();
Cell   cell   = set_cell();
Block  block  = set_block();
Frag   frag   = set_frag();

#if DEBUG_ENABLED == 1
Debug debug = set_debug();
#endif

#if STATS_ENABLED == 1
Stats stats = set_stats();
#endif
