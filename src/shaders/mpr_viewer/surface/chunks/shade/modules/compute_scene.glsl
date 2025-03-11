

// Compute light position
vec3 light_position = camera.position;

// Compute shading vectors
frag.light_vector = light_position - trace.position;
frag.view_vector = camera.position - trace.position;
frag.halfway_vector = frag.light_vector + frag.view_vector;

// Normalize shading vectors
frag.light_vector = normalize(frag.light_vector);
frag.view_vector = normalize(frag.view_vector);
frag.halfway_vector = normalize(frag.halfway_vector);

// Compute normal vector
frag.normal_vector = normalize(trace.gradient);
frag.normal_vector *= ssign(dot(frag.normal_vector, frag.view_vector));

// Compute vector angles
frag.light_angle = dot(frag.light_vector, frag.normal_vector);
frag.view_angle = dot(frag.view_vector, frag.normal_vector);
frag.halfway_angle = dot(frag.halfway_vector, frag.normal_vector);



