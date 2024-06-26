vec3 ray_step(vec3 direction, vec3 voxel, float resolution) {
    // computes ray box intersection voxel size vox, box_min = (0,0,0), box_max = voxel_step, ray_start = box_min, ray_dir = abs(dir)
    // scale values range from 0.7 to 10.0

    vec3 t_max = voxel / abs( direction ); 
    float delta = min(t_max.x,min(t_max.y,t_max.z));
    delta /= resolution;

    return delta * direction;
}
