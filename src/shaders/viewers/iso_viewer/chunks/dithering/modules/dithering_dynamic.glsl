
trace.dithering = random(trace.texel);
trace.dithering = clamp(trace.dithering, 0.0 + MILLI_TOL, 1.0 - MILLI_TOL);
trace.dithering *= trace.stepping * u_raycast.dithering_scale;
trace.stepping += trace.dithering;
