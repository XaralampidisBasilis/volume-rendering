
ray.step_tapering = 1.0 + smoothstep(0.0, ray.box_max_distance, ray.start_distance);
ray.max_step_tapering = 1.0 + smoothstep(0.0, ray.box_max_distance, ray.box_max_distance);

ray.step_tapering = min(ray.step_tapering, raymarch.max_step_tapering);
ray.max_step_tapering = min(ray.max_step_tapering, raymarch.max_step_tapering);

ray.min_step_scaling = raymarch.min_step_scaling * ray.step_tapering;
ray.max_step_scaling = raymarch.max_step_scaling * ray.step_tapering;
