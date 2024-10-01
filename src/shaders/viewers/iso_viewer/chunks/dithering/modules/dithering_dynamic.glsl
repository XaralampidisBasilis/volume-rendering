
trace.dithering = random(trace.texel);
trace.dithering = clamp(trace.dithering, 0.0 + EPSILON3, 1.0 - EPSILON3);
trace.dithering *= trace.stepping * u_raycast.dithering_scale;
trace.stepping += trace.dithering;
