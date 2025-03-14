

voxel.exit_distance = block.entry_distance;
voxel.exit_position = block.entry_position;

// int m_max = block.cheby_distance * 3;

for (int m = 0; m < MAX_VOXELS; m++) 
{
    // Compute min max positions 
    voxel.min_position = vec3(voxel.coords + 0) * u_volume.inv_dimensions;
    voxel.max_position = vec3(voxel.coords + 1) * u_volume.inv_dimensions;  

    // compute voxel entry from previous exit, 
    voxel.entry_distance = voxel.exit_distance;
    voxel.entry_position = voxel.exit_position;

    // compute voxel ray intersection to find exit, 
    voxel.exit_distance = intersect_box_max(voxel.min_position, voxel.max_position, camera.position, ray.direction, voxel.axis);
    voxel.exit_position = camera.position + ray.direction * voxel.exit_distance;

    // compute next voxel coordinates
    voxel.coords[voxel.axis] += ray.sign[voxel.axis];

    // compute break condition
    voxel.terminated = (voxel.coords[voxel.axis] == block.coords[block.axis]);

    if (voxel.terminated) 
    {
        break;
    }
}


