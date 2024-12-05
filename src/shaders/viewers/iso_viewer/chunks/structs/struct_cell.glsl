#ifndef STRUCT_CELL
#define STRUCT_CELL
struct Cell 
{
    vec3  size;
    vec3  local_position;
    vec3  min_position;
    vec3  max_position;
    vec3  min_coords;
    vec3  max_coords;
    float values[8]; // order c000, c1000, c010, c001, c011, c101, c110, c111
};

Cell set_cell()
{
    Cell cell;
    cell.size         = vec3(0.0);
    cell.min_position = vec3(0.0);
    cell.max_position = vec3(0.0);
    cell.coords       = ivec3(0);
    return cell;
}
void discard_cell(inout Cell cell)
{
    cell.size         = vec3(0.0);
    cell.min_position = vec3(0.0);
    cell.max_position = vec3(0.0);
    cell.coords       = ivec3(0);
}


#endif // STRUCT_CELL
