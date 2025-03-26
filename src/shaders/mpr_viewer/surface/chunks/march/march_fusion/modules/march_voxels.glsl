
#include "./start_voxel"

for (int n = 0; n < 30; n++) 
{
    #include "./update_voxel"

    if (voxel.intersected || voxel.terminated) 
    {
        break;
    }
}   