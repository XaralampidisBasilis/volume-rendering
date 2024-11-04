
ray.step_tapering = 1.0;
ray.step_tapering = min(ray.step_tapering, raymarch.max_step_tapering);

ray.step_distance *= ray.step_tapering;

