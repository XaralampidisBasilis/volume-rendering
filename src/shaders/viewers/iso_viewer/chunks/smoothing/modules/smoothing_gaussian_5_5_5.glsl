// https://homepages.inf.ed.ac.uk/rbf/HIPR2/mean.htm


const int size = 5; // Size of the grid in each dimension 
const int radius = 5 / 2;
const float sigma = float(radius);

vec3 texel_step = u_volume.inv_dimensions;
vec3 box_min = 0.0 - texel_step + EPSILON6;
vec3 box_max = 1.0 - box_min;
vec3 sample_texel;
float is_inside;

trace.value = 0.0;

for (int x = -radius; x <= radius; x++)  {
    for (int y = -radius; y <= radius; y++)  {
        for (int z = -radius; z <= radius; z++) {

            sample_offset = vec3(x, y, z);
            sample_texel = trace.texel + texel_step * sample_offset;
            is_inside = inside_box(box_min, box_max, sample_texel);

            sample_value = texture(u_sampler.volume, sample_texel).r * is_inside;
            kernel_value = gaussian(sample_offset, sigma) * is_inside;
            kernel_sum += kernel;

            trace.value += kernel_value * sample_value ;
        }
    }
}

trace.value /= kernel_sum;
trace.error = trace.value - u_raycast.threshold;
