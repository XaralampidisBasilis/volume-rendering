#ifndef STRUCT_CELL
#define STRUCT_CELL

struct Cell 
{
    ivec3 coords;
    ivec3 step_coords;
    vec3  min_position;
    vec3  max_position;
    vec2  bounds;
    vec4  distances;
    vec4  values;    
    vec4  coeffs;   
    float max_value; 
};

Cell set_cell()
{
    Cell cell;
    cell.coords       = ivec3(0);
    cell.step_coords  = ivec3(0);
    cell.min_position = vec3(0.0);
    cell.max_position = vec3(0.0);
    cell.bounds       = vec2(0.0);
    cell.distances    = vec4(0.0);
    cell.values       = vec4(0.0);
    cell.coeffs       = vec4(0.0);
    cell.max_value    = 0.0;
    return cell;
}

#endif 