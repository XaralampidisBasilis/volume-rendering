// https://homepages.inf.ed.ac.uk/rbf/HIPR2/mean.htm


const int size = 2 * SMOOTHING_RADIUS + 1;   // Size of the grid in each dimension
const int count = size * size * size; 

// Define texel step and box boundaries
vec3 texel_step = u_volume.inv_dimensions;
vec3 box_min = vec3(0.0) - texel_step + EPSILON6;
vec3 box_max = vec3(1.0) - box_min;
float coeff = 1.0 / float(count); 

// Main loop through kernel offsets
vec4 sample_data[count];
int index = 0;

for (int x = -SMOOTHING_RADIUS; x <= SMOOTHING_RADIUS; x++) {
    for (int y = -SMOOTHING_RADIUS; y <= SMOOTHING_RADIUS; y++) {
        for (int z = -SMOOTHING_RADIUS; z <= SMOOTHING_RADIUS; z++) {

            sample_data[index].xyz =  trace.texel + texel_step * vec3(x, y, z);
            sample_data[index].a = coeff * inside_box(box_min, box_max, sample_data[index].xyz);
            index++;
        }
    }
}

float kernel_sum = 0.0; // Initialize kernel sum for normalization
trace.value = 0.0;  // Initialize trace value to zero
for(int i= 0; i < count; i++)
{
    trace.value += sample_data[i].a * texture(u_sampler.volume, sample_data[i].xyz).r;
    kernel_sum += sample_data[i].a;
}

// Normalize the final trace value
trace.value /= kernel_sum;

// Compute trace error relative to the raycast threshold
trace.error = trace.value - u_raycast.threshold;
