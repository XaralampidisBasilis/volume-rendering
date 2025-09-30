// Source: https://learnwebgl.brown37.net/09_lights/lights_combined.html

// Compute shading vectors
vec3 light_position = camera.position;
vec3 light_vector = light_position - hit.position;
vec3 view_vector = camera.position - hit.position;

// Compute shading directions
vec3 light_direction = normalize(light_vector * u_volume.spacing);
vec3 view_direction = normalize(view_vector * u_volume.spacing);
vec3 halfway_direction = normalize(light_direction + view_direction);

// Compute vector angles
float light_angle = dot(light_direction, hit.normal);
float view_angle = dot(view_direction, hit.normal);
float halfway_angle = dot(halfway_direction, hit.normal);

// Compute parameters
float lambertian = clamp(light_angle, 0.0, 1.0);
float specular = clamp(halfway_angle, 0.0, 1.0);
specular = pow(specular, u_shading.shininess);

// Colors 
frag.color_material = colormap(hit.value, u_volume.colormap);
frag.color_ambient = frag.color_material * u_shading.reflect_ambient;
frag.color_diffuse = frag.color_material * u_shading.reflect_diffuse  * lambertian;
frag.color_specular = frag.color_material + (1.0 - frag.color_material) * u_shading.reflect_specular * specular;
frag.color_directional = mix(frag.color_diffuse, frag.color_specular, specular);

// Modulations
float edges_modulation = smoothstep(0.0, 0.5, abs(view_angle));
float gradient_modulation = mix(0.2, 1.0, smoothstep(0.0, 0.1, length(hit.gradient)));
float curvature_modulation = mean(smoothstep(-1.2, 0.0, hit.curvatures.x), smoothstep(-1.2, 0.0, hit.curvatures.y)); 

edges_modulation = mix(1.0, edges_modulation, u_shading.modulate_edges);
gradient_modulation = mix(1.0, gradient_modulation, u_shading.modulate_gradient);
curvature_modulation = mix(1.0, curvature_modulation, u_shading.modulate_curvature);

frag.color_directional *= mmin(edges_modulation, gradient_modulation);
frag.color_ambient *= curvature_modulation;

// Compose colors
frag.color = frag.color_ambient + frag.color_directional;

// Assign frag color
fragColor = vec4(frag.color, 1.0);

// Discard fragment
#if DISCARDING_ENABLED == 1
fragColor.rgb *= hit.discarded ? 0.0 : 1.0;
#endif

// #if DISCARDING_ENABLED == 1
// if (hit.discarded) discard;
// #endif

