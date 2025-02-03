#ifndef STRUCT_CELL
#define STRUCT_CELL


struct Cell 
{
    bool  intersected;
    bool  terminated;
    ivec3 coords;
    ivec3 coords_step;
    vec3  min_position;
    vec3  max_position;
    float entry_distance;
    float exit_distance;
    vec4  sample_intensities;    
    vec4  sample_distances;
    vec4  intensity_coeffs;    
};

Cell set_cell()
{
    Cell cell;
    cell.intersected        = false;
    cell.terminated         = false;
    cell.coords             = ivec3(0);
    cell.coords_step        = ivec3(0);
    cell.min_position       = vec3(0.0);
    cell.max_position       = vec3(0.0);
    cell.entry_distance     = 0.0;
    cell.exit_distance      = 0.0;
    cell.sample_intensities = vec4(0.0);
    cell.sample_distances   = vec4(0.0);
    cell.intensity_coeffs   = vec4(0.0);
    return cell;
}

#endif 
