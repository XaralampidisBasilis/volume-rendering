Camera camera     = set_camera();
Box    box        = set_box();
Ray    ray        = set_ray();
Trace  trace      = set_trace();
Voxel  voxel      = set_voxel();
Trace  prev_trace = set_trace();
Voxel  prev_voxel = set_voxel();
Frag   frag       = set_frag();

#if DEBUG_ENABLED == 1
Debug debug = set_debug();
#endif

#if STATS_ENABLED == 1
Stats stats = set_stats();
#endif
