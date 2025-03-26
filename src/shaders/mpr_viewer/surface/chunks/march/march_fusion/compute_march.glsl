
#include "./modules/start_trace"

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
    #include "./modules/march_voxels"
}

#include "./modules/end_march"
