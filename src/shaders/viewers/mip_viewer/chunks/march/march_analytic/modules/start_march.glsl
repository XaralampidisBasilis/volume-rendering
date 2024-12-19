

// start sampling constants
const vec4 sample_distances = vec4(0.0, 1.0/3.0, 2.0/3.0, 1.0);
const mat4 sample_matrix = mat4(
     1.0, -5.5,   9.0,   -4.5,
     0.0,  9.0, -22.5,   13.5,
     0.0, -4.5, 18.0, -13.5,
    0.0, 1.0, -4.5,   4.5 
);

// start cell
cell.step_coords = ivec3(0.0);
cell.coords = ivec3(ray.start_position * u_volume.inv_spacing + 0.5);
cell.bounds.y = ray.start_distance;
cell.distances.w = ray.start_distance;
cell.values.w = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * cell.distances.w).r;

// start trace
trace.distance = ray.start_distance;
trace.position = ray.start_position;
proj_trace = trace;

// start voxel
proj_voxel.value = ray.min_value;