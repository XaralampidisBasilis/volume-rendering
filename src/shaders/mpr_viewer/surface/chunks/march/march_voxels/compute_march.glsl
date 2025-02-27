
// start march at ray start
#include "./modules/start_march"

for (int count = 0; count < MAX_VOXELS; count++) 
{
    #include "./modules/update_voxel"

    if (voxel.occupied || voxel.terminated) 
    {
        break;
    }
}   

// compute gradient at trace
#include "./modules/compute_trace"
#include "./modules/compute_gradient"
