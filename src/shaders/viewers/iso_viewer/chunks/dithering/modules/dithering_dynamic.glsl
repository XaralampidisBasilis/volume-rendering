
trace.dithering = random(trace.voxel_texture_coords);
trace.dithering = clamp(trace.dithering, 0.0 + MILLI_TOL, 1.0 - MILLI_TOL);
trace.dithering *= trace.step_scaling * raymarch.dithering_scale;
trace.step_scaling += trace.dithering;
