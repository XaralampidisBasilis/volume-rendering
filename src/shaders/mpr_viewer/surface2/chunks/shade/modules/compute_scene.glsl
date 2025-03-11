
// Compute light position in texture coordinated
vec3 light_position = camera.position;

// Compute shading vectors in texture coordinated
frag.light_vector = light_position - trace.position;
frag.view_vector = camera.position - trace.position;
frag.halfway_vector = frag.light_vector + frag.view_vector;

// Normalize shading vectors in model coordinates
vec3 scale = normalize(u_intensity_map.size);
frag.light_vector = normalize(frag.light_vector * scale);
frag.view_vector = normalize(frag.view_vector * scale);
frag.halfway_vector = normalize(frag.halfway_vector * scale);

// Compute normal vector
frag.normal_vector = normalize(trace.gradient);
frag.normal_vector *= ssign(dot(frag.normal_vector, frag.view_vector));

// Compute vector angles
frag.light_angle = dot(frag.light_vector, frag.normal_vector);
frag.view_angle = dot(frag.view_vector, frag.normal_vector);
frag.halfway_angle = dot(frag.halfway_vector, frag.normal_vector);



