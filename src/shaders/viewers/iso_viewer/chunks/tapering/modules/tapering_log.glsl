float ray_tapering_scale = 100.0 * length(volume.spacing);

ray.step_tapering     = log(10.0 + ray.start_distance * ray_tapering_scale);
ray.max_step_tapering = log(10.0 + ray.box_max_distance * ray_tapering_scale);

ray.step_tapering     = min(ray.step_tapering, raymarch.max_step_tapering);
ray.max_step_tapering = min(ray.max_step_tapering, raymarch.max_step_tapering);

ray.min_step_scaling = raymarch.min_step_scaling * ray.step_tapering;
ray.max_step_scaling = raymarch.max_step_scaling * ray.step_tapering;
