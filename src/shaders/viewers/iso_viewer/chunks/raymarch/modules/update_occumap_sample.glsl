
block.coords = ivec3(trace.position / block.size);
float occupancy = texelFetch(u_sampler.occumaps, block.coords + occumap_offset, 0).r;
block.occupied = occupancy > 0.0;