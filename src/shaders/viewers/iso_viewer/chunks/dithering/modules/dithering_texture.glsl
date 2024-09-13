
// Calculate the end position of the ray.
vec3 ray_position = ray.origin + ray.direction * ray.min_distance;

// Compute a position value based on the end position transformed by the matrix.
vec4 sample_position = v_projection_model_view_matrix * vec4(ray_position, 1.0);

// Perform perspective division to get NDC space.
sample_position /= sample_position.w;

// Calculate NDC position in the range [0, 1].
sample_position = (sample_position + 1.0) * 0.5; 

// Subdivide the screen into multiple tilings.
sample_position *= 1000.0; 

// Sample the noise map texture at xy coordinates.
ray.dithering = texture(u_sampler.noisemap, sample_position.xy).r * ray.max_spacing;    
