void skip_space
( 
    in vec3 ray_step, 
    in int skip_steps, 
    inout vec3 ray_position,
    inout int i_step
) 
{
    ray_position = ray_position + ray_step * float(skip_steps);
    i_step = i_step + skip_steps;
}