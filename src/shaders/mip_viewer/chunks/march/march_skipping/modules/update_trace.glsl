
// update trace
trace.distance = cell.exit_distance;
trace.position = camera.position + ray.direction * trace.distance; 

// update maximum intensity projection trace
if (mip.intensity < trace.intensity)
{
    mip = trace;
}
