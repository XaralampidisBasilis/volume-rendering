float ray_tapering_scale = 0.5 * length(volume.size);
ray.step_tapering = 1.0 + smoothstep(0.0, ray.box_max_distance, ray.start_distance / ray_tapering_scale);
ray.step_tapering = min(ray.step_tapering, raymarch.max_step_tapering);

ray.step_distance *= ray.step_tapering;
