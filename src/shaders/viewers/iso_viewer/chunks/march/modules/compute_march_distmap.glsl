
// Compute ray entry with bounding volume
for (block.skip_count = 0; block.skip_count < u_rendering.max_skip_count; block.skip_count++) 
{
    // Compute block coords from ray start position
    block.coords = ivec3(ray.start_position * u_distmap.inv_spacing);

    // Sample the distance map and compute if block is occupied
    block.value = int(texelFetch(u_textures.distmap, block.coords, 0).r * 255.0) - 1;
    block.occupied = block.value <= 0;

    // Compute block min max coords in distance map
    block.min_coords = block.coords - block.value + 1;
    block.max_coords = block.coords + block.value + 0;

    // Compute block min max position in model space  
    block.min_position = (vec3(block.min_coords) - CENTI_TOLERANCE) * u_distmap.spacing;
    block.max_position = (vec3(block.max_coords) + CENTI_TOLERANCE) * u_distmap.spacing;
    if (block.occupied) break;   

    ray.start_distance = intersect_box_max(block.min_position, block.max_position, ray.camera_position, ray.step_direction);
    ray.start_position = ray.camera_position + ray.step_direction * ray.start_distance; 
    if (ray.start_distance > ray.end_distance) break;
}

// Discard ray if no intersection with bounding volume
if (ray.start_distance > ray.end_distance)
{
    #include "./discard_ray"
}
else 
{
    ray.span_distance = ray.end_distance - ray.start_distance;
}

