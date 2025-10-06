// Start ray
#include "./modules/start_ray"

// Compute intersection of ray with volume box
#include "./modules/intersect_box"

// Compute intersection of ray with bounding box
#if BBOX_ENABLED == 1
#include "./modules/intersect_bbox"
#endif
