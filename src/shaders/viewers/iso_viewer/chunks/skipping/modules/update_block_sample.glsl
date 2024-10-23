
block.coords = ivec3(trace.position / occumap.spacing);
ivec3 occumap_coords = occumap.offset + block.coords;
block.occupied = texelFetch(u_sampler.occumaps, occumap_coords, 0).r > 0.0;
