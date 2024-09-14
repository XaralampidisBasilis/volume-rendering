
// calculate the end position of the ray.
vec3 ray_min_position = ray.origin + ray.direction * ray.min_distance;

// compute a position value based on the end position transformed by the matrix.
vec4 sample_position = v_projection_model_view_matrix * vec4(ray_min_position, 1.0);

// perform perspective division to get NDC space.
sample_position /= sample_position.w;

// calculate NDC position in the range [0, 1].
sample_position = (sample_position + 1.0) * 0.5; 

// subdivide the screen into multiple tilings.
sample_position *= 1000.0; 

// sample the noise map texture at xy coordinates.
ray.dithering = texture(u_sampler.noisemap, sample_position.xy).r * ray.max_spacing;    
