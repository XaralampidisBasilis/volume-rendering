
block.coords = ivec3(trace.position / occumap.spacing);
block.occupied = texelFetch(u_sampler.occumaps, occumap.offset + block.coords, 0).r > 0.0;
