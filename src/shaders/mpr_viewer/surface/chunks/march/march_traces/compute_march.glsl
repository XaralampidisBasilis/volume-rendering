
#include "./modules/start_trace"

for (int n = 0; n < MAX_VOXELS; n++) 
{
    #include "./modules/update_trace"

    if (trace.intersected || trace.terminated) 
    {
        break;
    }
}   

#include "./modules/end_march"
