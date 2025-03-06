
// start march at ray start
#include "./modules/start_march"

for (int n = 0; n < u_debugging.max_voxels; n++) 
{
    #include "./modules/update_voxel"

    if (voxel.terminated) 
    {
        break;
    }
}   

#include "./modules/end_march"
