
#include "./modules/start_march"

for (int n = 0; n < MAX_VOXELS; n++) 
{
    #include "./modules/update_trace"

    if (trace.intersected || trace.terminated) 
    {
        break;
    }
}   

if (trace.intersected)
{
    #include "./modules/start_refine"

    for (int n = 0; n < 30; n++) 
    {
        #include "./modules/update_voxel"

        if (voxel.intersected || voxel.terminated) 
        {
            break;
        }
    }   
}

#include "./modules/end_march"
