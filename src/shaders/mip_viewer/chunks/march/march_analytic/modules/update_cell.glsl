
// compute cell bounding box in model coordinates
cell.coords += cell.coords_step;
cell.min_position = (vec3(cell.coords) - 0.5) * u_intensity_map.spacing;
cell.max_position = (vec3(cell.coords) + 0.5) * u_intensity_map.spacing;

// compute cell ray intersection to find entry and exit distances, 
cell.entry_distance = cell.exit_distance;
cell.exit_distance = intersect_box_max
(
    cell.min_position, 
    cell.max_position, 
    camera.position, 
    ray.direction, 
    cell.coords_step
);

// given the entry and exit compute the sampling distances inside the cell
cell.sample_distances.x = cell.sample_distances.w;
cell.sample_distances.yzw = mmix(cell.entry_distance, cell.exit_distance, weights_vec4.yzw);

// compute the intensity samples inside the cell from the intensity map texture
cell.sample_intensities.x = cell.sample_intensities.w;
cell.sample_intensities.y = texture(u_textures.intensity_map, camera.uvw + ray.uvw_direction * cell.sample_distances.y).r;
cell.sample_intensities.z = texture(u_textures.intensity_map, camera.uvw + ray.uvw_direction * cell.sample_distances.z).r;
cell.sample_intensities.w = texture(u_textures.intensity_map, camera.uvw + ray.uvw_direction * cell.sample_distances.w).r;

// from the sampled intensities we can compute the trilinear interpolation cubic polynomial coefficients
cell.intensity_coeffs = inv_vander_mat4 * cell.sample_intensities;

// given the polynomial we can compute if we intersect the isosurface inside the cell
trace.intersected = is_cubic_solvable
(
    cell.intensity_coeffs, 
    u_rendering.intensity, 
    0.0, 
    1.0, 
    cell.sample_intensities.x, 
    cell.sample_intensities.w
);
