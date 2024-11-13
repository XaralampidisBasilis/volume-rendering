
// min and max available lods for maching
float marching_min_lod = max(0.0, float(u_raymarch.min_skip_lod));
float marching_max_lod = min(2.0, float(u_raymarch.max_skip_lod));
float select_lod = ray.span_distance / ray.max_span_distance;

// start at the coarsest level of detail available
occumap.lod = int(mix(marching_min_lod, marching_max_lod, select_lod));
occumap.lod = u_raymarch.min_skip_lod;
occumap.lod_scale = floor(exp2(float(occumap.lod)));

// compute occumap parameters
occumap.dimensions = u_occumaps.base_dimensions / int(occumap.lod_scale);
occumap.spacing = u_occumaps.base_spacing * occumap.lod_scale;
occumap.inv_dimensions = 1.0 / vec3(occumap.dimensions); 
occumap.inv_spacing = 1.0 / occumap.spacing; 

// compute occumap start coordinates inside occumaps atlas
occumap.start_coords.y = u_occumaps.base_dimensions.y  - 2 * occumap.dimensions.y;
occumap.start_coords.z = u_occumaps.base_dimensions.z;
if (occumap.lod == 0) occumap.start_coords = ivec3(0);

// compute occumap start texture coordinates inside occumaps atlas
occumap.start_texture_coords = vec3(occumap.start_coords) * u_occumaps.inv_dimensions;

// Sample occumaps atlas at the current occumap level of detail
vec3 block_coords = trace.position * occumap.inv_spacing;

// find block coords of trace position in current occumap
occumap.block_coords = ivec3(floor(block_coords));
occumap.block_texture_coords = block_coords * u_occumaps.inv_dimensions;

// compute occumaps atlas coordinates for current occumap level of detail
ivec3 occumaps_coords = occumap.start_coords + occumap.block_coords;
vec3 occumaps_texture_coords = occumap.start_texture_coords + occumap.block_texture_coords;

// sample the occumaps atlas and check if block is occupied
// occumap.block_occupancy = textureLod(u_textures.occumaps, occumaps_texture_coords, 0.0).r;
occumap.block_occupancy = texelFetch(u_textures.occumaps, occumaps_coords, 0).r;
occumap.block_occupied = occumap.block_occupancy > 0.0;