
// update trace
trace.distance = cell.exit_distance;
trace.position = camera.position + ray.direction * trace.distance; 
trace.terminated = trace.distance > ray.end_distance;

// update maximum intensity projection trace
if (mip.intensity < trace.intensity)
{
    mip = trace;
}
