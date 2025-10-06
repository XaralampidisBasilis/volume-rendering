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

// Modulations
float modulate_edges = smoothstep(0.0, 0.5, abs(view_angle));
float modulate_gradient = mix(0.2, 1.0, smoothstep(0.0, 0.1, length(hit.gradient)));
float modulate_curvature = mean(smoothstep(-1.2, 0.0, hit.curvatures.x), smoothstep(-1.2, 0.0, hit.curvatures.y)); 

modulate_edges = mix(1.0, modulate_edges, u_shading.modulate_edges);
modulate_gradient = mix(1.0, modulate_gradient, u_shading.modulate_gradient);
modulate_curvature = mix(1.0, modulate_curvature, u_shading.modulate_curvature);

// Colors 
frag.color_material = colormap(hit.value, u_shading.colormap);
frag.color_ambient = frag.color_material * u_shading.reflect_ambient;
frag.color_diffuse = frag.color_material * u_shading.reflect_diffuse  * lambertian;
frag.color_specular = frag.color_material + (1.0 - frag.color_material) * u_shading.reflect_specular * specular;
frag.color_directional = mix(frag.color_diffuse, frag.color_specular, specular);

frag.color_directional *= mmin(modulate_edges, modulate_gradient);
frag.color_ambient *= modulate_curvature;

// Compose colors
frag.color = frag.color_ambient + frag.color_directional;
fragColor = vec4(frag.color, 1.0);

#if DISCARDING_ENABLED == 1
fragColor.a *= hit.discarded ? 0.0 : 1.0;
#endif
