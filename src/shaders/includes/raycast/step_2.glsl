vec3 ray_step_2(vec3 direction, vec2 range, vec3 voxel, float resolution) {
    // computes ray box intersection voxel size vox, box_min = (0,0,0), box_max = voxel_step, ray_start = box_min, ray_dir = abs(dir)
    // scale values range from 0.7 to 10.0

    float voxel_min = min(voxel.x, min(voxel.y, voxel.x));
    float depth = range.y - range.x;
    float steps = ceil(resolution * depth / voxel_min);
    float delta = depth / steps;

    return delta * direction;
}
