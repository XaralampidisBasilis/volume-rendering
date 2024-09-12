vec4 trilinear_interpolation
(   
    sampler3D tex, 
    vec3 tex_coords, 
    vec3 tex_size
) 
{
    // Calculate the normalized texture coordinates
    vec3 normalized_coords = tex_coords * tex_size - 0.5;
    
    // Find the integer coordinates of the texels
    vec3 i0 = floor(normalized_coords);
    vec3 i1 = i0 + vec3(1.0);
    
    // Calculate the fractional part of the coordinates
    vec3 f = fract(normalized_coords);
    
    // Fetch the texel values at the surrounding texels
    vec4 c000 = texture(tex, (i0.xyz + vec3(0.5)) / tex_size);
    vec4 c100 = texture(tex, (i1.xzy + vec3(0.5)) / tex_size);
    vec4 c010 = texture(tex, (i0.xzy + vec3(0.5)) / tex_size);
    vec4 c110 = texture(tex, (i1.xzz + vec3(0.5)) / tex_size);
    vec4 c001 = texture(tex, (i0.zyx + vec3(0.5)) / tex_size);
    vec4 c101 = texture(tex, (i1.zxy + vec3(0.5)) / tex_size);
    vec4 c011 = texture(tex, (i0.zxy + vec3(0.5)) / tex_size);
    vec4 c111 = texture(tex, (i1.zzz + vec3(0.5)) / tex_size);
    
    // Interpolate along the x-axis
    vec4 c00 = mix(c000, c100, f.x);
    vec4 c10 = mix(c010, c110, f.x);
    vec4 c01 = mix(c001, c101, f.x);
    vec4 c11 = mix(c011, c111, f.x);
    
    // Interpolate along the y-axis
    vec4 c0 = mix(c00, c10, f.y);
    vec4 c1 = mix(c01, c11, f.y);
    
    // Interpolate along the z-axis
    vec4 c = mix(c0, c1, f.z);
    
    return c;
}
